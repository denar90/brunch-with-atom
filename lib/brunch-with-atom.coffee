{CompositeDisposable, BufferedNodeProcess, NotificationManager} = require 'atom'
{$} = require 'atom-space-pen-views'
BrunchMenu = require './brunch-menu'
skeletonsUrl = 'https://raw.githubusercontent.com/brunch/skeletons/master/skeletons.json'
#const commands
commands = {
  NEW: 'new',
  BUILD: 'build',
  WATCH: 'watch',
  STOP: 'stop'
}

getSkeletonsWithAliases = (skeletons) ->
  item for item in skeletons when item.alias != undefined

module.exports =
  modalPanel: null
  subscriptions: null
  process: null

  activate: (state) ->
    self = @
    callback = (response) ->
      #init modal panel for sekeltons list
      self.modalPanel = new BrunchMenu({
        #set list skeletons for panel
        skeletons: getSkeletonsWithAliases(response.skeletons)
        afterConfirmed: (item) ->
          #run brunch command when item in panel was choosen
          self.runBrunchCommand(['new', item.alias])
      })

    # get available skeletons
    $.get skeletonsUrl, callback, 'json'

    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable

    # Register command that toggles this view
    @subscriptions.add atom.commands.add 'atom-workspace', "brunch:new": => @warmBrunch(commands.NEW)
    @subscriptions.add atom.commands.add 'atom-workspace', "brunch:build": => @warmBrunch(commands.BUILD)
    @subscriptions.add atom.commands.add 'atom-workspace', "brunch:watch": => @warmBrunch(commands.WATCH)
    @subscriptions.add atom.commands.add 'atom-workspace', "brunch:stop": => @warmBrunch(commands.STOP)

  deactivate: ->
    @modalPanel.destroy()
    @subscriptions.dispose()

  warmBrunch: (type) ->
    if !@brunchIsReady()
      atom.notifications.addError('Brunch could not be run. Create project first')
      return

    switch type
      when commands.NEW
        @modalPanel.showModalPanel()
      when commands.BUILD
        @runBrunchCommand([type])
      when commands.WATCH
        @runBrunchCommand([type])
      when commands.STOP
        @stopBrunchProcess()
        atom.notifications.addSuccess('Brunch has been eaten :)')

  runBrunchCommand: (command) ->
    @stopBrunchProcess()
    args = command
    stdout = (line) -> atom.notifications.addSuccess(line)
    stderr = (line) -> atom.notifications.addWarning(line)
    exit = (code) -> atom.notifications.addSuccess("The process exited with code: #{code}")
    path = atom.project.getPaths()[0]
    packagePath = "#{atom.packages.getPackageDirPaths()}/brunch-with-atom"
    @process = new BufferedNodeProcess({
      command: "#{packagePath}/node_modules/.bin/brunch",
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
