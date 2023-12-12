; { \\ #Includes
#Include <Classes\Apps\Slack>
; }

SC03A & a::slack.button("reaction")
SC03A & e::slack.button("edit")
SC03A & d::slack.button("delete")

F1::Slack.unread("dm")
F2::Slack.unread("")