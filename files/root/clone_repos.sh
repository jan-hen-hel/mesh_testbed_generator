#!/bin/sh

git config --global user.name "<%= @node['hostname']%>"
git config --global user.email "<%= @node['hostname']%>@gnss.dev"

git clone -q git@github.com:jan-hen-hel/gnss-lab-dev.git /ssd/gnss-lab-dev
git clone -q git@github.com:jan-hen-hel/gnss-lab.git /ssd/gnss-lab
