#!/bin/bash
cd ${0%/*}
.stow() { [ -d $1 ] && (pushd $1 &>/dev/null; stow -t ../.. */; popd &>/dev/null) || echo $0: $1: No such directory; }

.stow public
.stow private

exit 0
