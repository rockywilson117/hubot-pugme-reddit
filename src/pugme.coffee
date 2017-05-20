# Description:
#   DogMe is an enhanced Pugme script,
#   because all doggos are the most important things in life.
#
# Dependencies:
#   underscore
#
# Configuration:
#   None
#
# Commands:
#   hubot dog me - Receive a doggo
#   hubot dog bomb N - Get N pugs
dogjson = [
  {
    dogtype: 'pug'
    subreddit: '/r/pugs'
  },
  {
    dogtype: 'corgi'
    subreddit: '/r/corgis'
  },
  {
    dogtype: 'pitbull'
    subreddit: '/r/pitbulls'
  },
  {
    dogtype: 'puggle'
    subreddit: '/r/puggle'
  },
  {
    dogtype: 'beagle'
    subreddit: '/r/beagles'
  }
]
  
_ = require 'underscore'
module.exports = (robot) ->
  robot.respond /dog me( ([\w\s-]+))?/i, (msg) ->
    reqdogtype = msg.match[2]
    robot.logger.debug reqdogtype
    if not reqdogtype?
      robot.logger.debug "dog me only"
      dogtype = _.sample(dogjson)
      robot.logger.info dogtype
      url = "https://www.reddit.com#{dogtype.subreddit}.json?sort=top&t=week"
      robot.logger.info url
    else if reqdogtype is "cat"
      msg.send "Cat is not a type of doggo. Dogs are better than cats."
      return
    else
        result = (item for item in dogjson when item.dogtype is reqdogtype)
        robot.logger.debug result.length
        if result.length is 0
          msg.send "#{reqdogtype} is not setup. Please request that it be added"
          return
        else
          robot.logger.info result
          dogtype = result[0]
          url = "https://www.reddit.com#{dogtype.subreddit}.json?sort=top&t=week"
          robot.logger.info url
    msg.http(url)
    .get() (err, res, body) ->
      try
        dogs = getDogs(body, 1)
      catch error
        robot.logger.error "[dogme] #{error}"
        msg.send "I'm brain damaged :("
        return
      msg.send "Here is a pretty #{dogtype.dogtype} " + dog for dog in dogs
  robot.respond /dog bomb( (\d+))?/i, (msg) ->
    count = msg.match[2]
    if not count
      count = if (msg.match.input.match /bomb/i)? then 5 else 1
      dogtype = _.sample(dogjson)
      url = "https://www.reddit.com#{dogtype.subreddit}.json?sort=top&t=week"
      robot.logger.info.url
    msg.http(url)
    .get() (err, res, body) ->
      try
        dogs = getDogs(body, count)
      catch error
        robot.logger.error "[dogme] #{error}"
        msg.send "I'm brain damaged :("
        return
      msg.send "Here is a pretty #{dogtype.dogtype} " + dog for dog in dogs
    

getDogs = (response, n) ->
  try
    posts = JSON.parse response
  catch error
    throw new Error "JSON parse failed"

  unless posts.data?.children? && posts.data.children.length > 0
    throw new Error "Could not find any posts"

  imagePosts = _.filter posts.data.children, (child) -> not child.data.is_self

  if n > imagePosts.length
    n = imagePosts.length

  return (imagePost.data.url for imagePost in (_.sample imagePosts, n))
