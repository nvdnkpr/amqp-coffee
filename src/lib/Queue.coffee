# Queues
debug = require('./config').debug('amqp:Queue')
Channel        = require('./Channel')
defaults       = require('./defaults')

{ methodTable, classes, methods } = require('./config').protocol

_              = require('underscore')

class Queue
  ###
    @args.name(required)
    @cb function required
  ###
  constructor: (channel, args, cb)->
    debug 3, ()->return ["New queue", JSON.stringify(args)]
    if !args.queue? and args.name?
      args.queue = args.name
      delete args['name']

    if !args.queue?
      cb("args.queue is required") if cb?
      return

    @queueOptions = _.defaults args, defaults.queue

    @channel  = channel
    @taskPush = channel.taskPush

    if cb? then cb(null, @)

  declare: (args, cb)->
    if typeof args is 'function'
      cb = args
      args = {}
      declareOptions = @queueOptions
    else
      declareOptions = _.defaults args, @queueOptions

    @taskPush methods.queueDeclare, declareOptions, methods.queueDeclareOk, cb

  bind: (exchange, routingKey, cb)=>
    queueBindOptions = {
      queue:      @queueOptions.queue
      exchange:   exchange
      routingKey: routingKey
      arguments: {}
    }
    @taskPush methods.queueBind, queueBindOptions, methods.queueBindOk, cb

  unbind: (exchange, routingKey, cb)=>
    queueUnbindOptions = {
      queue:      @queueOptions.queue
      exchange:   exchange
      routingKey: routingKey
      arguments: {}
    }
    @taskPush methods.queueUnbind, queueUnbindOptions, methods.queueUnbindOk, cb


  messageCount: (args, cb)=>
    if typeof args is 'function'
      cb = args
      args = {}

    @declare args, (err, res)->
      cb(err, res.messageCount)

  consumerCount: (args, cb)->
    if typeof args is 'function'
      cb = args
      args = {}

    @declare args, (err, res)->
      cb(err, res.consumerCount)

  delete: (args, cb)=>
    if typeof args is 'function'
      cb = args
      args = {}

    if !args? then args = {}

    queueDeleteArgs = _.defaults args, defaults.queueDelete, {queue: @queueOptions.queue}
    @taskPush methods.queueDelete, queueDeleteArgs, methods.queueDeleteOk, cb

module.exports = Queue
