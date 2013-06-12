#! /usr/bin/perl
use uni::perl;

use Linux::Input;
use Data::Dump;

my $rfid_reader_device = 'event10';

my $input = Linux::Input->new("/dev/input/$rfid_reader_device")
    or die "Cannot open input: $!\n";

# EVIOCGRAB 
ioctl($input->fh, 1074021776, 1);    # grab

while (1) {
    while (my @events = $input->poll()) {
        dd \@events;
    }
}
