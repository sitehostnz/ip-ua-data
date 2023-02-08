#!/bin/bash
USER_AGENTS_DIR="user-agents"
mkdir -p "$USER_AGENTS_DIR"

#https://github.com/mitchellkrogza/nginx-ultimate-bad-bot-blocker
##Good UAs
wget -q -O - https://raw.githubusercontent.com/mitchellkrogza/nginx-ultimate-bad-bot-blocker/master/_generator_lists/good-user-agents.list > "$USER_AGENTS_DIR/trusted-user-agents"

##Allowed UAs
wget -q -O - https://raw.githubusercontent.com/mitchellkrogza/nginx-ultimate-bad-bot-blocker/master/_generator_lists/allowed-user-agents.list > "$USER_AGENTS_DIR/allowed-user-agents"

##Limited UAs
wget -q -O - https://raw.githubusercontent.com/mitchellkrogza/nginx-ultimate-bad-bot-blocker/master/_generator_lists/limited-user-agents.list > "$USER_AGENTS_DIR/limited-user-agents"

##Blocked UAs
wget -q -O - https://raw.githubusercontent.com/mitchellkrogza/nginx-ultimate-bad-bot-blocker/master/_generator_lists/bad-user-agents.list > "$USER_AGENTS_DIR/blocked-user-agents"

