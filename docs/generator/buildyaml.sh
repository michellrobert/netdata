#!/bin/bash

GENERATOR_DIR="docs/generator"
cd ${GENERATOR_DIR}/src

# create yaml nav subtree with all the files directly under a specific directory
# arguments:
# tabs - how deep do we show it in the hierarchy. Level 1 is the top level, max should probably be 3
# directory - to get mds from to add them to the yaml
# file - can be left empty to include all files
# name - what do we call the relevant section on the navbar. Empty if no new section is required
# maxdepth - how many levels of subdirectories do I include in the yaml in this section. 1 means just the top level and is the default if left empty
# excludefirstlevel - Optional param. If passed, mindepth is set to 2, to exclude the READMEs in the first directory level

navpart() {
	tabs=$1
	dir=$2
	file=$3
	section=$4
	maxdepth=$5
	excludefirstlevel=$6
	spc=""

	i=1
	while [ ${i} -lt ${tabs} ]; do
		spc="    $spc"
		i=$((i + 1))
	done

	if [ -z "$file" ]; then file='*'; fi
	if [[ -n $section ]]; then echo "$spc- ${section}:"; fi
	if [ -z "$maxdepth" ]; then maxdepth=1; fi
	if [[ -n $excludefirstlevel ]]; then mindepth=2; else mindepth=1; fi

	for f in $(find $dir -mindepth $mindepth -maxdepth $maxdepth -name "${file}.md" -printf '%h\0%d\0%p\n' | sort -t '\0' -n | awk -F '\0' '{print $3}'); do
		# If I'm adding a section, I need the child links to be one level deeper than the requested level in "tabs"
		if [ -z "$section" ]; then
			echo "$spc- '$f'"
		else
			echo "$spc    - '$f'"
		fi
	done
}

echo -e 'site_name: Netdata Documentation
repo_url: https://github.com/netdata/netdata
repo_name: GitHub
edit_uri: blob/master
site_description: Netdata Documentation
copyright: Netdata, 2018
docs_dir: src
site_dir: build
#use_directory_urls: false
strict: true
google_analytics: ["UA-64295674-3", ""]
extra:
  social:
    - type: "github"
      link: "https://github.com/netdata/netdata"
    - type: "twitter"
      link: "https://twitter.com/linuxnetdata"
    - type: "facebook"
      link: "https://www.facebook.com/linuxnetdata/"
theme:
    name: "material"
    custom_dir: themes/material
extra_css:
  - "https://cdnjs.cloudflare.com/ajax/libs/cookieconsent2/3.1.0/cookieconsent.min.css"
extra_javascript:
  - "javascripts/cookie-consent.js"
  - "https://cdnjs.cloudflare.com/ajax/libs/cookieconsent2/3.1.0/cookieconsent.min.js"
markdown_extensions:
 - extra
 - abbr
 - attr_list
 - def_list
 - fenced_code
 - footnotes
 - tables
 - admonition
 - codehilite
 - meta
 - nl2br
 - sane_lists
 - smarty
 - toc:
    permalink: True
    separator: "-"
 - wikilinks
 - pymdownx.arithmatex
 - pymdownx.betterem:
    smart_enable: all
 - pymdownx.caret
 - pymdownx.critic
 - pymdownx.details
 - pymdownx.emoji:
    emoji_generator: !!python/name:pymdownx.emoji.to_svg
 - pymdownx.inlinehilite
 - pymdownx.magiclink
 - pymdownx.mark
 - pymdownx.smartsymbols
 - pymdownx.superfences
 - pymdownx.tasklist:
    custom_checkbox: true
 - pymdownx.tilde
 - pymdownx.betterem
 - pymdownx.superfences
 - markdown.extensions.footnotes
 - markdown.extensions.attr_list
 - markdown.extensions.def_list
 - markdown.extensions.tables
 - markdown.extensions.abbr
 - pymdownx.extrarawhtml
nav:'

navpart 1 . README "About"

echo -ne "    - 'docs/Why-Netdata.md'
    - 'docs/Demo-Sites.md'
    - 'docs/netdata-security.md'
    - 'docs/Donations-netdata-has-received.md'
    - 'docs/a-github-star-is-important.md'
    - REDISTRIBUTED.md
    - CHANGELOG.md
    - CONTRIBUTING.md
"

echo -ne "- Installation:
    - 'installer/README.md'
    - 'packaging/docker/README.md'
    - 'installer/UPDATE.md'
    - 'installer/UNINSTALL.md'
"

echo -ne "- 'docs/GettingStarted.md'
"

echo -ne "- Running netdata:
"
navpart 2 daemon
navpart 2 daemon/config

navpart 2 web/server "" "Web server"
navpart 3 web/server "" "" 2 excludefirstlevel
echo -ne "        - Running behind another web server:
            - 'docs/Running-behind-nginx.md'
            - 'docs/Running-behind-apache.md'
            - 'docs/Running-behind-lighttpd.md'
            - 'docs/Running-behind-caddy.md'
"
#navpart 2 system
navpart 2 database
navpart 2 registry

echo -ne "    - 'docs/Performance.md'
    - 'docs/netdata-for-IoT.md'
    - 'docs/high-performance-netdata.md'
"

navpart 1 collectors "" "Data collection" 1
echo -ne "    - 'docs/Add-more-charts-to-netdata.md'
    - Internal plugins:
"
navpart 3 collectors/apps.plugin
navpart 3 collectors/proc.plugin
navpart 3 collectors/statsd.plugin
navpart 3 collectors/cgroups.plugin
navpart 3 collectors/idlejitter.plugin
navpart 3 collectors/tc.plugin
navpart 3 collectors/nfacct.plugin
navpart 3 collectors/checks.plugin
navpart 3 collectors/diskspace.plugin
navpart 3 collectors/freebsd.plugin
navpart 3 collectors/macos.plugin

navpart 2 collectors/plugins.d "" "External plugins"
navpart 3 collectors/python.d.plugin "" "Python modules" 3
navpart 3 collectors/node.d.plugin "" "Node.js modules" 3
navpart 3 collectors/charts.d.plugin "" "BASH modules" 3
echo -ne "            - 'collectors/charts.d.plugin/README.md'
            - 'collectors/charts.d.plugin/ap/README.md'
            - 'collectors/charts.d.plugin/apcupsd/README.md'
            - 'collectors/charts.d.plugin/example/README.md'
            - 'collectors/charts.d.plugin/libreswan/README.md'
            - 'collectors/charts.d.plugin/nut/README.md'
            - 'collectors/charts.d.plugin/opensips/README.md'
        - Obsolete BASH modules:
            - 'collectors/charts.d.plugin/mem_apps/README.md'
            - 'collectors/charts.d.plugin/postfix/README.md'
            - 'collectors/charts.d.plugin/tomcat/README.md'
            - 'collectors/charts.d.plugin/sensors/README.md'
            - 'collectors/charts.d.plugin/cpu_apps/README.md'
            - 'collectors/charts.d.plugin/squid/README.md'
            - 'collectors/charts.d.plugin/nginx/README.md'
            - 'collectors/charts.d.plugin/hddtemp/README.md'
            - 'collectors/charts.d.plugin/cpufreq/README.md'
            - 'collectors/charts.d.plugin/mysql/README.md'
            - 'collectors/charts.d.plugin/exim/README.md'
            - 'collectors/charts.d.plugin/apache/README.md'
            - 'collectors/charts.d.plugin/load_average/README.md'
            - 'collectors/charts.d.plugin/phpfpm/README.md'
"

navpart 3 collectors/fping.plugin
navpart 3 collectors/freeipmi.plugin

echo -ne "    - 'docs/Third-Party-Plugins.md'
"

navpart 1 health README "Alarms and notifications"
navpart 2 health/notifications "" "" 1
navpart 2 health/notifications "" "Supported notifications" 2 excludefirstlevel

navpart 1 streaming "" "" 4

navpart 1 backends "" "Archiving to backends" 3

navpart 1 web "README" "Dashboards"
navpart 2 web/gui "" "" 3

navpart 1 web/api "" "HTTP API"
navpart 2 web/api/exporters "" "Exporters" 2
navpart 2 web/api/formatters "" "Formatters" 2
navpart 2 web/api/badges "" "" 2
navpart 2 web/api/health "" "" 2
navpart 2 web/api/queries "" "Queries" 2

echo -ne "- Hacking netdata:
    - CODE_OF_CONDUCT.md
    - 'docs/Netdata-Security-and-Disclosure-Information.md'
    - CONTRIBUTORS.md
"
navpart 2 makeself "" "" 4
navpart 2 libnetdata "" "libnetdata" 4
navpart 2 contrib
navpart 2 tests
navpart 2 diagrams/data_structures
