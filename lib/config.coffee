Wercker        = require 'wercker'
wercker_status = require './wercker_status'

class WerckerConfig
    ctx = null
    wercker = new Wercker()

    init: (cb) ->
        ctx = this
        if !@get_config().user
            @reset_config()
            cb(false)
        else if !this.get_config().token
            @get_set_token(cb)
        else
            cb(true)

    get_config: () ->
        interval = Number(atom.config.get('wercker-status.Interval_Minutes')) || 2
        return user =
            user     : atom.config.get 'wercker-status.Username'
            pass     : atom.config.get 'wercker-status.Password'
            token    : atom.config.get 'wercker-status.Token'
            interval : ((1000 * (60 * interval)) || 10000)

    reset_config: () ->
        atom.config.set 'wercker-status.Token', null
        atom.config.set 'wercker-status.Username', ''
        atom.config.set 'wercker-status.Password', ''
        atom.config.set 'wercker-status.Interval_Minutes', 2

    set_token: (token) ->
        atom.config.set 'wercker-status.Token', token

    get_set_token: (cb) ->
        user = @get_config()
        wercker.request_oauth_token user.user, user.pass, (err, result) ->
            return console.log(err) if err
            if result.data?.accessToken
                ctx.set_token(result.data.accessToken)
                cb(true)
            else if result.errorMessage
                wercker_status.set_status(result.errorMessage)
            else
                cb(false)

module.exports = new WerckerConfig
