#!/usr/bin/env perl
use strict;
use warnings;
use utf8;
use open qw(:std :utf8);

my $rus_mode = (@ARGV && $ARGV[0] eq '-r') ? (shift @ARGV, 1) : 0;

my @faces = qw(:3 :* :^ :> ;3 :P :D >w< ^~^ ^_^ ^w^ >_< UwU OwO O.o);
my @actions_en = ('holds your hand','meows softly','purrs','wags tail','twitches ears','smiles playfully','seductively looks at you');
my @actions_ru = ('взял за ручку','мяукает','мурчит','махает хвостиком','поджимает ушки','игриво улыбается','соблазняет глазками');
my @between_en = ('*meow*','*purr*');
my @between_ru = ('*мяу*','*мур*');

sub rand_chance { rand() < $_[0] }

sub replace_letters {
    my $t = shift;
    $t =~ s/[rR]/$& eq 'R' ? 'W' : 'w'/ge;
    $t =~ s/[vV]/$& eq 'V' ? 'F' : 'f'/ge;
    $t =~ s/[Вв]/$& eq 'В' ? 'Ф' : 'ф'/ge;
    if (rand_chance(0.7)) {
        $t =~ s/[bB]/$& eq 'B' ? 'P' : 'p'/ge;
        $t =~ s/[gG]/$& eq 'G' ? 'K' : 'k'/ge;
        $t =~ s/[lL]/$& eq 'L' ? 'W' : 'w'/ge;
        $t =~ s/[Гг]/$& eq 'Г' ? 'Х' : 'х'/ge;
        $t =~ s/[Лл]/$& eq 'Р' ? 'В' : 'в'/ge;
    }
    $t;
}

sub add_stutter {
    my $w = shift;
    if ($w =~ /^[A-Z]/) {
        my ($f, $r) = (substr($w,0,1), lc substr($w,1));
        return rand_chance(0.2) ? "$f-$f-$r"
             : rand_chance(0.4) ? "$f-$r"
             : "$f$r";
    }
    my $f = substr($w,0,1);
    return rand_chance(0.2) ? "$f-$f-$w"
         : rand_chance(0.4) ? "$f-$w"
         : $w;
}

sub insert_stutter_meow {
    my ($line,$rus) = @_;
    my @between = $rus ? @between_ru : @between_en;
    my @words = split /(\s+)/, $line;
    my @out;
    for (my $i=0; $i<@words; $i+=2) {
        $words[$i] =~ /\w/ and $words[$i] = add_stutter($words[$i]);
        push @out, $words[$i];
        if ($i+1 < @words) {
            push @out, (rand_chance(0.15) ? " ".$between[rand @between] : ""), $words[$i+1];
        }
    }
    join '', @out;
}

sub select_face { $faces[int rand @faces] }
sub select_action { $_[0] ? $actions_ru[int rand @actions_ru] : $actions_en[int rand @actions_en] }

sub process_line {
    my ($line,$rus) = @_;
    chomp $line;
    $line = replace_letters($line);
    my @parts = split /([.?!])/, $line;
    my $out = '';
    for (my $i=0; $i<@parts; $i+=2) {
        $out .= insert_stutter_meow($parts[$i],$rus);
        if ($i+1 < @parts) {
            $out .= $parts[$i+1];
            my $r = rand;
            $out .= $r < 0.4 ? " ".select_face()
                  : $r < 0.8 ? " *".select_action($rus)."*"
                  : "...~";
        }
    }
    $out;
}

print process_line($_, $rus_mode), "\n" while <STDIN>;
