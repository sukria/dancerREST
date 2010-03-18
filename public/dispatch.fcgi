#!/home/franck/local/bin/perl
use Plack::Handler::FCGI;

my $app = do('/home/franck/tmp/dancerREST/app.psgi');
my $server = Plack::Handler::FCGI->new(nproc  => 5, detach => 1);
$server->run($app);
