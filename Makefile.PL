use ExtUtils::MakeMaker;

WriteMakefile(
    NAME         => "Bot::BasicBot::Pluggable::Module::SimpleBlog",
    VERSION_FROM => "lib/Bot/BasicBot/Pluggable/Module/SimpleBlog.pm",
    PREREQ_PM    => { Bot::BasicBot::Pluggable => '0.04',
		      Carp                     => 0,
                      DBD::SQLite              => 0,
                      Regexp::Common           => 0,
                      Time::Piece              => 0 }
);

