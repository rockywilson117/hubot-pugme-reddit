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
#   hubot pug bomb N - Get N pugs

_ = require 'underscore'
dogarray = ["pugs" , "corgis" , "pitbulls", "puggle", "beagles"]
module.exports = (robot) ->
  robot.respond /dog me|dog bomb( (\d+))?/i, (msg) ->
    count = msg.match[2]
    if not count
      count = if (msg.match.input.match /bomb/i)? then 5 else 1
      dogtype = _.sample(dogarray)
    msg.http("http://www.reddit.com/r/#{dogtype}.json?sort=top&t=week")
    .get() (err, res, body) ->
      try
        dogs = getDogs(body, count)
      catch error
        robot.logger.error "[dogme] #{error}"
        msg.send "I'm brain damaged :("
        return

      msg.send dog for dog in dogs

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
