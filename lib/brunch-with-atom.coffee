{CompositeDisposable, BufferedNodeProcess, NotificationManager} = require 'atom'
{$} = require 'atom-space-pen-views'
Promise = require('bluebird');
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
    callback = (response) ->
      #init modal panel for sekeltons list
      self.chooseSkeletonModal = new BrunchMenu({
        #set list skeletons for panel
        menuItems: getSkeletonsWithAliases(response.skeletons)
        afterConfirmed: (item) ->
          #run brunch command when item in panel was choosen
          self.runBrunchCommand(['new', item.alias])
      })

    # get available skeletons
    $.get skeletonsUrl, callback, 'json'

  activateVersionsMenu: ->
    self = @
    @repo = gitty("#{atom.packages.getPackageDirPaths()}/brunch-with-atom/brunch")
    @repo.getTags (error, tags) ->
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

      self.changeVersionModal = new BrunchMenu({
        menuItems: menuItems
        afterConfirmed: (item) ->
          #run brunch command when item in panel was choosen
          self.repo.checkoutSync(item.tag)
          atom.notifications.addSuccess("Brunch version was chenged to #{item.tag}")
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
    args = command
    stdout = (line) -> atom.notifications.addWarning(line)
    stderr = (line) -> atom.notifications.addWarning(line)
    exit = (code) -> atom.notifications.addSuccess("The process exited with code: #{code}")
    path = atom.project.getPaths()[0]
    packagePath = "#{atom.packages.getPackageDirPaths()}/brunch-with-atom"
    @process = new BufferedNodeProcess({
      command: "#{packagePath}/brunch/.bin/brunch",
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

  brunchIsReady: ->
    projectPath = atom.project.getPaths()[0]
    if projectPath
      return true
    else
      return false
