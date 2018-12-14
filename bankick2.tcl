##########################################
#       DaZa's bankick.tcl ver 1.0       #
#      For Eggdrop 1.1.x Series Bots     #
#   For Info Email daza@speednet.com.au  #
##########################################

# This is a complete package for adding bans, permanent bans (shit) or
# kicking users from a channel.

# Command to use are as follows:

# PUBLIC COMMANDS:
# !banhost <user@host> <reason> - temp bans a user@host from current channel
# !shithost <channel> <user@host> <reason> - perm bans a user@host
# !ban <nick> <reason> - temp bans a user from current channel
# !shit <channel> <nick> - perm bans a user
# !clearbans - empties the current channels ban list

# MSG COMMANDS:
# !banhost <channel> <user@host> <reason> - temp bans a user@host from current channel 
# !shithost <channel> <user@host> <reason> - perm bans a user@host
# !ban <channel> <nick> <reason> - temp bans a user from current channel
# !shit <channel> <nick> - perm bans a user
# !clearbans <channel> - empties the current channels ban list

# NOTE: All shits (perm bans) are channel specific only. In other words
# they apply to the channel specified in <channel> comming in a later ver
# will be commands to add global bans to all channels.

### MAIN SCRIPT ###

### Ban a user@host ###

proc pub_banhost {nick hand uhost chan var} {
  if {$var == ""} {
  putserv "NOTICE $nick :Usage is !banhost <channel> <user@host> <reason>"
  return 0
  }
  set target [lindex $var 0]
  if {[matchchanattr $uhost o $chan]} {
  putserv "MODE $chan +b $target"
  putlog "$nick banned $target"
  } else {
  putserv "NOTICE $nick :Sorry you are not an Op on $chan..."
  putlog "$nick attempted to ban $target"
  }
  return 1
}
bind pub - !bh pub_banhost
bind pub - !banhost pub_banhost

proc msg_banhost {nick hand uhost var} {
  if {$var == ""} {
  putserv "NOTICE $nick :Usage is !banhost <channel> <user@host> <reason>"
  return 0
  }
  set chan [lindex $var 0]
  set who [lrange $var 1 1]
  if {[matchchanattr $uhost o $chan]} {
  putserv "MODE $chan +b $who"
  putlog "$nick banned $target"
  } else {
  putserv "NOTICE $nick :Sorry you are not an Op on $chan..."
  putlog "$nick attempted to ban $target"
  }
  return 1
}
bind msg - !bh msg_banhost
bind msg - !banhost msg_banhost

### Shitlist a user@host ###

proc pub_shithost {nick hand uhost chan var} {
  if {$var == ""} {
  putserv "NOTICE $nick :Usage is !shithost <channel> <user@host> <reason>"
  return 0
  }
  set chn [lindex $var 0]
  set target [lrange $var 1 1]
  set reason [lrange $var 2 end]
  if {$reason == ""} {set reason "Git Outta Here!"}
  if {[matchchanattr $uhost o $chn]} {
  newchanban $chn $target $nick $reason 0
  putlog "$nick shitted $target on $chn for $reason"
  } else {
  putserv "NOTICE $nick :Sorry you are not an Op on $chn!"
  putlog "$nick attempted to shit $target for $reason"
  } 
  return 1
}
bind pub - !sh pub_shithost
bind pub - !shithost pub_shithost

proc msg_shithost {nick hand uhost var} {
  if {$var == ""} {
  putserv "NOTICE $nick :Usage is !shithost <channel> <user@host> <reason>"
  return 0
  }
  set chn [lindex $var 0]
  set target [lrange $var 1 1]
  set reason [lrange $var 2 end]
  if {$reason == ""} {set reason "Git Outta Here!"}
  if {[matchchanattr $uhost o $chn]} {
  newchanban $chn $target $nick $reason 0
  putlog "$nick shitted $target on $chn for $reason"
  } else {
  putserv "NOTICE $nick :Sorry you are not an Op on $chn!"
  putlog "$nick attempted to shit $target for $reason"
  } 
  return 1
}
bind msg - !sh msg_shithost
bind msg - !shithost msg_shithost

### Ban a nick!user@host ###

proc pub_bankick {nick hand uhost chan var} {
  global botnick
  if {$var == ""} {
    putserv "NOTICE $nick :Usage: !ban <nick> <reason>"
    return 0
  }
  set target [lindex $var 0]
  set reason [lrange $var 1 end]
  if {[matchchanattr $uhost o $chan]} {
  if {![onchan $botnick $chan]} {
    putserv "NOTICE $nick :I am not on $chan!"
    return 0
  }
  if {![botisop $chan]} {
    putserv "NOTICE $nick :I am not an Op on $chan!"
    return 0
  }
  if {![onchan $target $chan]} {
    putserv "NOTICE $nick :$target is not on $chan!"
    return 0
  }
  set bantarget [maskhost [getchanhost $target $chan]]
  set bantrim [string trimleft $bantarget ?*!~?]
  append banmask "*!*" $bantrim
  append userhost $target "!" [getchanhost $target $chan]
  set target [finduser $userhost]
  if {([matchchanattr $target f $chan] || [matchattr $target m] || [matchchanattr $target o $chan] || [matchattr $target b])} {
    putserv "NOTICE $nick :Can't ban a Master, Friend, Bot, or Channel Op, sorry."
    return 0
  }
  if {$reason == ""} {set reason "Your Outta Here!"}
  putserv "MODE $chan +b $banmask"
  putserv "KICK $chan $target :$reason"
  putlog "$nick banned $target at $banmask for $reason"
  return 1
  } else {
  putserv "NOTICE $nick :Sorry you are not an Op on $chan..."
  putlog "$nick attempted ban $target at $banmask for $reason on $chan"
} 
}
bind pub - !bk pub_bankick
bind pub - !ban pub_bankick
bind pub - !bankick pub_bankick

proc msg_bankick {nick hand uhost var} {
  global botnick
  if {$var == ""} {
    putserv "NOTICE $nick :Usage: !ban <chan> <nick> <reason>"
    return 0
  }
  set chan [lindex $var 0]
  set target [lrange $var 1 1]
  set reason [lrange $var 2 end]
  if {[matchchanattr $uhost o $chan]} {
  if {![onchan $botnick $chan]} {
    putserv "NOTICE $nick :I am not on $chan!"
    return 0
  }
  if {![botisop $chan]} {
    putserv "NOTICE $nick :I am not an Op on $chan!"
    return 0
  }
  if {![onchan $target $chan]} {
    putserv "NOTICE $nick :$target is not on $chan!"
    return 0
  }
  set bantarget [maskhost [getchanhost $target $chan]]
  set bantrim [string trimleft $bantarget ?*!~?]
  append banmask "*!*" $bantrim
  append userhost $target "!" [getchanhost $target $chan]
  set target [finduser $userhost]
  if {([matchchanattr $target f $chan] || [matchattr $target m] || [matchchanattr $target o $chan] || [matchattr $target b])} {
    putserv "NOTICE $nick :Can't ban a Master, Friend, Bot, or Channel Op, sorry."
    return 0
  }
  if {$reason == ""} {set reason "Your Outta Here!"}
  putserv "MODE $chan +b $banmask"
  putserv "KICK $chan $target :$reason"
  putlog "$nick banned $target at $banmask for $reason"
  return 1
  } else {
  putserv "NOTICE $nick :Sorry you are not an Op on $chan..."
  putlog "$nick attempted ban $target at $banmask for $reason on $chan"
} 
}
bind msg - !bk msg_bankick
bind msg - !ban msg_bankick
bind msg - !bankick msg_bankick

### Shitlist a nick!user@host ###

proc pub_shit {nick hand uhost chan var} {
  global botnick
  if {$var == ""} {
    putserv "NOTICE $nick :Usage: !shit <channel> <nick> <reason>"
    return 0
  }
  set chn [lindex $var 0]
  set target [lrange $var 1 1]
  set reason [lrange $var 2 end]
  if {[matchchanattr $uhost o $chn]} {
  set bantarget [maskhost [getchanhost $target $chn]]
  set bantrim [string trimleft $bantarget ?*!~?]
  append banmask "*!*" $bantrim
  append userhost $target "!" [getchanhost $target $chn]
  set target [finduser $userhost]
  if {([matchchanattr $target f $chn] || [matchattr $target m] || [matchchanattr $target o $chn] || [matchattr $target b])} {
    putserv "NOTICE $nick :Can't shit a Master, Friend, Bot, or Channel Op, sorry."
    return 0
  }
  if {$reason == ""} {set reason "Your Outta Here!"}
  newchanban $chn $banmask $nick $reason 0
  putserv "KICK $chn $target :$reason"
  putlog "$nick shitted $target at $banmask on $chn"
  return 1
  } else {
  putserv "NOTICE $nick :Sorry you are not an Op on $chn!"
  putlog "$nick attempted to shit $nick on $chn"
  }
}
bind pub - !shit pub_shit

proc msg_shit {nick hand uhost var} {
  global botnick
  if {$var == ""} {
    putserv "NOTICE $nick :Usage: !shit <channel> <nick> <reason>"
    return 0
  }
  set chn [lindex $var 0]
  set target [lrange $var 1 1]
  set reason [lrange $var 2 end]
  if {[matchchanattr $uhost o $chn]} {
  set bantarget [maskhost [getchanhost $target $chn]]
  set bantrim [string trimleft $bantarget ?*!~?]
  append banmask "*!*" $bantrim
  append userhost $target "!" [getchanhost $target $chn]
  set target [finduser $userhost]
  if {([matchchanattr $target f $chn] || [matchattr $target m] || [matchchanattr $target o $chn] || [matchattr $target b])} {
    putserv "NOTICE $nick :Can't shit a Master, Friend, Bot, or Channel Op, sorry."
    return 0
  }
  if {$reason == ""} {set reason "Your Outta Here!"}
  newchanban $chn $banmask $nick $reason 0
  putserv "KICK $chn $target :$reason"
  putlog "$nick shitted $target at $banmask on $chn"
  return 1
  } else {
  putserv "NOTICE $nick :Sorry you are not an Op on $chn!"
  putlog "$nick attempted to shit $nick on $chn"
  }
}
bind msg - !shit msg_shit

### Kick a Nick ###

proc pub_kick {nick hand uhost chan var} {
  set who [lindex $var 0]
  set reason [lrange $var 1 end]
  if {[matchchanattr $uhost o $chan]} {
  putserv "KICK $chan $who :$reason"
  return 1
  } else {
  putserv "NOTICE $nick :Sorry you are not an Op on $chan..."
 }
}
bind pub - !kick pub_kick
bind pub - !k pub_kick

proc msg_kick {nick hand uhost var} {
  set chan [lindex $var 0]
  set who [lrange $var 1 1]
  set reason [lrange $var 2 end]
  if {[matchchanattr $uhost o $chan]} {
  putserv "KICK $chan $who :$reason"
  return 1
  } else {
  putserv "NOTICE $nick :Sorry you are not an Op on $chan..."
 }
}
bind msg - !kick msg_kick
bind msg - !k msg_kick

### Clear Channel Ban List ###

proc pub_clearbans {nick hand uhost chan var} {
  putserv "NOTICE $nick :Clearing bans on $chan ..."
  foreach x [chanbans $chan] {
    pushmode $chan -b $x
  }
  return 1
}
bind pub m !cb pub_clearbans
bind pub m !clearbans pub_clearbans

proc msg_clearbans {nick hand uhost var} {
  set chan [lindex $var 0]
  putserv "NOTICE $nick :Clearing bans on $chan ..."
  foreach x [chanbans $chan] {
    pushmode $chan -b $x
  }
}
bind msg m !cb msg_clearbans
bind msg m !clearbans msg_clearbans

putlog "bankick.tcl ver 1.0 by DaZa loaded successfully..."
