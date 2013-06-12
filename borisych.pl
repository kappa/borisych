#! /usr/bin/perl
use uni::perl;

use Linux::Input;
use Data::Dump;

my $rfid_reader_device = 'by-id/usb-EHUOYAN.cn_RfidLoginer-event-kbd';

local $ENV{MPD_HOST} = 'tatlisu';
my %commands = (
    ',4,2,10,8,4,8,2,6,3,9'   => mpc('Аквариум - Сестра Хаос'),
    ',4,11,7,2,8,3,5,3,10,7'  => mpc('Аквариум - Беспечный русский бродяга'),
    ',11,10,6,4,3,11,7,5,8,6' => 'mpc stop',
);

sub mpc {
    my $playlist = shift;

    return "mpc stop && mpc clear && mpc load '$playlist' && mpc play";
}

sub process_event {
    my $event = shift;

    state $current_string = '';

    if (   $event->{type}  == 1     # key up
        && $event->{value} == 0)
    {
        if ($event->{code}  == 28) {    # Enter
            process_string($current_string);
            $current_string = '';
        }
        else {
            $current_string .= ",$event->{code}";
        }
    }
}

sub process_string {
    my $string = shift;

    state $prev_string = '';

    if (!$string || $string eq $prev_string) {
        return;
    }

    if (my $command = $commands{$string}) {
        system($command);
    }

    $prev_string = $string;
}

my $input = Linux::Input->new("/dev/input/$rfid_reader_device")
    or die "Cannot open input: $!\n";

# EVIOCGRAB 
ioctl($input->fh, 1074021776, 1);    # grab

while (1) {
    while (my @events = $input->poll()) {
        process_event($_) for @events;
    }
}
