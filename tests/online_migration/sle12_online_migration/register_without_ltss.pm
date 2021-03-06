# SLE12 online migration tests
#
# Copyright © 2017 SUSE LLC
#
# Copying and distribution of this file, with or without modification,
# are permitted in any medium without royalty provided the copyright
# notice and this notice are preserved.  This file is offered as-is,
# without any warranty.

# Summary: sle12 online migration testsuite
# Maintainer: Wei Jiang <wjiang@suse.com>

use base "console_yasttest";
use strict;
use testapi;
use migration;

sub run() {
    select_console 'root-console';

    de_register(version_variable => 'HDDVERSION');
    remove_ltss;
    # Set this variable to skip registration and repos validation of LTSS
    set_var('SKIP_LTSS', 1);
    register_system_in_textmode;
}

sub test_flags {
    return {fatal => 1};
}

1;
# vim: set sw=4 et:
