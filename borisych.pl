#! /usr/bin/perl
use uni::perl;

use Linux::Input;

my $rfid_reader_device = 'by-id/usb-EHUOYAN.cn_RfidLoginer-event-kbd';

local $ENV{MPD_HOST} = 'tatlisu';
my %commands = (
    ',4,2,10,8,4,8,2,6,3,9'   => mpc('Аквариум - Сестра Хаос'),
    ',4,11,7,2,8,3,5,3,10,7'  => mpc('Аквариум - Беспечный русский бродяга'),
    ',4,4,7,5,2,7,11,7,5,9'   => mpc('ДДТ - Прекрасная любовь'), # myataya
    ',4,8,4,11,6,8,3,5,3,5'   => mpc('David Sylvian - Dead bees on a cake'),
    ',2,8,10,7,10,10,9,3,9,11'=> mpc('Elton John - Made In England'),
    ',4,9,7,7,4,7,4,11,2,7'   => mpc('Maire Brennan - Whisper To The Wild Water'),
	',4,2,10,7,2,3,7,4,5,5'	  => mpc('Mike Oldfield - Two Sides'),
	',4,4,3,3,11,9,7,6,4,7'   => mpc('Pink Floyd - Relics'),
	',2,5,5,6,2,4,6,5,10,7'   => mpc('Joe Dassin'),
	',4,11,6,6,3,3,4,10,5,5'  => mpc('Ноль'),
	',11,2,5,6,4,7,11,11,11,9'=> mpc('Аквариум - Феодализм'),
    ',11,10,6,4,3,11,7,5,8,6' => 'mpc stop',
    ',4,2,9,3,8,5,4,6,5,7'    => 'mpc toggle',
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

    say "Got string: [$string]";
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
