#!/usr/bin/env bash
#  vim:ts=4:sts=4:sw=4:et
#
#  Author: Hari Sekhon
#  Date: 2015-05-25 01:38:24 +0100 (Mon, 25 May 2015)
#
#  https://github.com/harisekhon
#
#  License: see accompanying Hari Sekhon LICENSE file
#
#  If you're using my code you're welcome to connect with me on LinkedIn and optionally send me feedback to help improve or steer this or other code I publish
#
#  http://www.linkedin.com/in/harisekhon
#

set -eu
srcdir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

cd "$srcdir/..";
for x in $(echo *.pl *.py *.rb 2>/dev/null); do
    [[ "$x" =~ ^\* ]] && continue
    [[ "$x" = "check_puppet.rb" ]] && continue
    set +e
    # ignore zookeeper as it may not be built
    grep -q "Net::ZooKeeper" "$x" && { echo "skipping $x due to Net::ZooKeeper dependency which may not be built"; continue; }
    commit="$(git log "$x" | head -n1 | grep 'commit')"
    if [ -z "$commit" ]; then
        continue
    fi
    echo ./$x --help
    ./$x --help # >/dev/null
    status=$?
    set -e
    # quick hack for older programs
    [ "$x" = "check_dhcpd_leases.py" -o "$x" = "check_linux_ram.py" ] && [ $status = 0 ] && { echo "allowing $x to have zero exit code"; continue; }
    [ $status = 3 ] || { echo "status code for $x --help was $status not expected 3"; exit 1; }
done
echo "All Perl / Python / Ruby programs found exited with expected code 3 for --help"
