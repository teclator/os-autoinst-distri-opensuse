#!/usr/bin/perl -w
use strict;
use base "installstep";
use bmwqemu;

sub run() {
    my $self = shift;

    # start install
    if ( $ENV{UPGRADE} ) {
        sendkey $cmd{update};
        sleep 1;
        my $ret = waitforneedle( [qw/startupdate startupdate-conflict/], 5 );

        while ( $ret->{needle}->has_tag("startupdate-conflict") ) {
            $self->take_screenshot;
            sendkeyw $cmd{ok};

            sendkeyw $cmd{change};
            sendkeyw $cmd{"package"};
            waitforneedle( "package-conflict", 5 );
            $self->take_screenshot;
            sendkeyw "alt-1";    # We hope that zypper makes the best suggestion here
            sendkeyw $cmd{ok};

            waitforneedle( "package-resolve-conflict", 5 );
            sendkeyw $cmd{accept};

            waitforneedle( "automatic-changes", 5 );
            sendkeyw $cmd{"continue"};

            sendkey $cmd{update};
            sleep 1;
            $ret = waitforneedle( [qw/startupdate startupdate-conflict/], 5 );
        }

        # confirm
        $self->take_screenshot;
        sendkey $cmd{update};

        sleep 5;

        # view installation details
        sendkey $cmd{instdetails};
    }
    else {
        sendkey $cmd{install};
        waitforneedle("startinstall");

        # confirm
        $self->take_screenshot;
        sendkey $cmd{install};
        waitforneedle("inst-packageinstallationstarted");
    }
    if ( !$ENV{LIVECD} && !$ENV{NICEVIDEO} && !$ENV{UPGRADE} && !checkEnv( 'VIDEOMODE', 'text' ) ) {
        while (1) {
            my $ret = checkneedle( [ 'installation-details-view', 'inst-bootmenu', 'grub2' ], 3 );
            if ( defined($ret) ) {
                last if $ret->{needle}->has_tag("installation-details-view");
                # intention to let this test fail
                waitforneedle( 'installation-details-view', 1 ) if ( $ret->{needle}->has_tag("inst-bootmenu") || $ret->{needle}->has_tag("grub2") );
            }
            sendkey $cmd{instdetails};
        }
        if ( $ENV{DVD} && !$ENV{NOIMAGES} ) {
            if ( checkEnv( 'DESKTOP', 'kde' ) ) {
                waitforneedle( 'kde-imagesused', 500 );
            }
            elsif ( checkEnv( 'DESKTOP', 'gnome' ) ) {
                waitforneedle( 'gnome-imagesused', 500 );
            }
            elsif ( !checkEnv( "DESKTOP", "textmode" ) ) {
                waitforneedle( 'x11-imagesused', 500 );
            }
        }
    }
}

1;
# vim: set sw=4 et:
