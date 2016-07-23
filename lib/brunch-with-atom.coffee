{CompositeDisposable, BufferedProcess, BufferedNodeProcess, NotificationManager} = require 'atom'
{$} = require 'atom-space-pen-views'
gitty = require 'gitty';
BrunchMenu = require './brunch-menu'
skeletonsUrl = 'https://raw.githubusercontent.com/brunch/skeletons/master/skeletons.json'
#const commands
commands = {
  NEW: 'new',
  BUILD: 'build',
  WATCH: 'watch',
  STOP: 'stop',
  CHANGE_VERSION: 'change_version'
}

getSkeletonsWithAliases = (skeletons) ->
  item for item in skeletons when item.alias != undefined

module.exports =
  chooseSkeletonModal: null
  changeVersionModal: null
  subscriptions: null
  process: null
  repo: null

  activate: (state) ->
    try
      @activateSkeletonsMenu()
      @activateVersionsMenu()
    catch error
      atom.notifications.addWarning('Brunch couldn\'t get sekeltons')
      atom.notifications.addWarning('Brunch command `new` will be not avaliable')

    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable

    # Register command that toggles this view
    @subscriptions.add atom.commands.add 'atom-workspace', "brunch:new": => @warmBrunch(commands.NEW)
    @subscriptions.add atom.commands.add 'atom-workspace', "brunch:build": => @warmBrunch(commands.BUILD)
    @subscriptions.add atom.commands.add 'atom-workspace', "brunch:watch": => @warmBrunch(commands.WATCH)
    @subscriptions.add atom.commands.add 'atom-workspace', "brunch:stop": => @warmBrunch(commands.STOP)
    @subscriptions.add atom.commands.add 'atom-workspace', "brunch:change_version": => @warmBrunch(commands.CHANGE_VERSION)

  activateSkeletonsMenu: ->
    self = @
    callback = (response) =>
      #init modal panel for sekeltons list
      @chooseSkeletonModal = new BrunchMenu({
        #set list skeletons for panel
        menuItems: getSkeletonsWithAliases(response.skeletons)
        afterConfirmed: (menuItem) =>
          #run brunch command when item in panel was choosen
          @runBrunchCommand(['new', menuItem.alias])
      })

    # get available skeletons
    $.get skeletonsUrl, callback, 'json'

  activateVersionsMenu: ->
    self = @
    @repo = gitty(@getBrunchRepoPath())
    @repo.getTags (error, tags) =>
      if error
        atom.notifications.addError(error)

      currentBranch = self.repo.getBranchesSync()

      tags = tags.reverse()
      menuItems = [];

      $.each tags, (index, tag) ->
        selected = false;

        if currentBranch.current.indexOf(tag) isnt -1
          selected = true;

        menuItems.push {
          description: tag,
          tag: tag,
          selected: selected
        }

      @changeVersionModal = new BrunchMenu({
        menuItems: menuItems
        afterConfirmed: (menuItem) =>
          #run brunch command when item in panel was choosen
          @repo.checkoutSync(menuItem.tag)
          atom.notifications.addSuccess("Brunch version was chenged to #{menuItem.tag}")
          @updateBrunch()
      })

  deactivate: ->
    @chooseSkeletonModal.destroy()
    @changeVersionModal.destroy()
    @subscriptions.dispose()

  warmBrunch: (type) ->
    if !@brunchIsReady()
      atom.notifications.addError('Brunch could not be run. Create project first')
      return

    switch type
      when commands.NEW
        if @chooseSkeletonModal
          @chooseSkeletonModal.showModalPanel()
      when commands.BUILD
        @runBrunchCommand([type])
      when commands.WATCH
        @runBrunchCommand([type])
      when commands.STOP
        @stopBrunchProcess()
        atom.notifications.addSuccess('Brunch has been eaten :)')
      when commands.CHANGE_VERSION
        @changeVersionModal.showModalPanel()

  runBrunchCommand: (command) ->
    atom.notifications.addSuccess('Brunch has been started :)')
    @stopBrunchProcess()
    path = atom.project.getPaths()[0]
    brunchRepoPath = @getBrunchRepoPath()

    args = command
    stdout = (line) -> atom.notifications.addWarning(line)
    stderr = (line) -> atom.notifications.addWarning(line)
    exit = (code) -> atom.notifications.addSuccess("The process exited with code: #{code}")
    @process = new BufferedNodeProcess({
      command: "#{brunchRepoPath}/bin/brunch",
      options: {
        cwd: path
      },
      args: args,
      stdout: stdout,
      stderr: stderr,
      exit: exit
    })

  stopBrunchProcess: ->
    # if process was run - kill it
    if @process != null
      @process.kill()
      @process = null

  getBrunchRepoPath: ->
    return "#{atom.packages.getPackageDirPaths()}/brunch-with-atom/brunch"

  brunchIsReady: ->
    projectPath = atom.project.getPaths()[0]
    if projectPath
      return true
    else
      return false

  updateBrunch: ->
    atom.notifications.addSuccess("Brunch update was started. Wait untill success message.")
    path = atom.project.getPaths()[0]
    brunchRepoPath = @getBrunchRepoPath()
    stdout = (line) -> atom.notifications.addWarning(line)
    stderr = (line) -> atom.notifications.addWarning(line)
    exit = (code) -> atom.notifications.addSuccess("Brunch is ready to use.")
    process = new BufferedProcess({
      command: 'bash'
      args: ['update-brunch.sh'],
      options: {
        cwd: path
      },
      stdout: stdout,
      stderr: stderr,
      exit: exit
    })
