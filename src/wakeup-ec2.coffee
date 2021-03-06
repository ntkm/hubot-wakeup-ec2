# Description
#   Start your EC2 instance
#
# Configuration:
#   LIST_OF_ENV_VARS_TO_SET
#
# Commands:
#   hubot start instance TagKey=TagValue - <Start your instances where TagKey = TagValue>
#   hubot stop instance TagKey=TagValue - <Stop your instances where TagKey = TagValue>
#
# Notes:
#   <optional notes required for the script>
#
# Author:
#   ntkm <aui.tkm@gmail.com>

REGION = 'ap-northeast-1'
async = require('async')

AWS = require('aws-sdk')

if process.env.AWS_ACCESS_KEY_ID? and process.env.AWS_SECRET_ACCESS_KEY?
  AWS.config.update({
    accessKeyId: process.env.AWS_ACCESS_KEY_ID,
    secretAccessKey: process.env.AWS_SECRET_ACCESS_KEY
  })
else
  AWS.config.loadFromPath(process.env.AWS_SECRET_PATH || "#{process.env.HOME}/secrets/credentials.json")

AWS.config.update({region: process.env.AWS_REGION || REGION})

handleInstance = (ec2, instance, toHandle) ->
  params = { InstanceIds: [instance.InstanceId] }

  if toHandle is 'start'
    ec2.startInstances(params, (err, data) ->
      console.log(err, err.stack) if err?
    )
  else if toHandle is 'stop'
    ec2.stopInstances(params, (err, data) ->
      console.log(err, err.stack) if err?
    )

module.exports = (robot) ->
  robot.respond /(start|stop) instance ([^ =]+)?=([^ =]+)?$/i, (res) ->
    toHandle = res.match[1]
    tagKey = res.match[2]
    tagValue = res.match[3]

    res.send "#{toHandle}ing your EC2 Instances."

    ec2 = new AWS.EC2()
    params = {
      Filters: [
        {
          Name: 'tag-key',
          Values: [tagKey]
        },
        {
          Name: 'tag-value',
          Values: [tagValue]
        }
      ]
    }

    ec2.describeInstances(params, (err, data) ->
      if err? res.send "#{err} with stacktrace: #{err.stack}"
      else
        async.forEach(data.Reservations, (reservation, callback)->
          instance = reservation.Instances[0]

          res.send "Instance: id = #{instance.InstanceId}"

          if toHandle is 'start' and instance.State.Name is 'running'
            res.send 'already running!'
          else if toHandle is 'stop' and instance.State.Name isnt 'running'
            res.send 'already stopping or stoped.'
          else
            handleInstance(ec2, instance, toHandle)
            res.reply "#{toHandle}ed instance: id = #{instance.InstanceId}"
          callback()
        , () ->
          res.send 'All Done!!'
        )
    )
