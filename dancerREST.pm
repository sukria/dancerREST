package dancerREST;
use Dancer ':syntax';

my %users = ();

get '/' => sub {
    template "index.tt";
};

# return a list of users
# curl -H "Content-Type: application/json" http://localhost:5000/api/user/
# => [{"name":"foo","id":"1"}]
get '/api/user/' => sub {
    my @users;
    push @users, { name => $users{$_}->{name}, id => $_ } foreach keys %users;
    return \@users;
};

# return a specific user
# curl -H "Content-Type: application/json" http://localhost:5000/api/user/1
# => {"name":"foo"}
get '/api/user/:id' => sub {
    my $params = request->params;
    if ( exists $users{ $params->{id} } ) {
        return $users{$params->{id}};
    }
    else {
        return { error => "unknown user" };
    }
};

# create a new user
# curl -H "Content-Type: application/json" -X POST http://localhost:5000/api/user/ -d '{"name":"foo","id":1}'
# => {"name":"foo","id":"1"}
post '/api/user/' => sub {
    my $params = request->params;
    if ( $params->{name} && $params->{id} ) {
        if ( exists $users{ $params->{id} } ) {
            return { error => "user already exists" };
        }
        $users{$params->{id}} = {name => $params->{name}};
        return { id => $params->{id}, name => $params->{name} };
    }
    else {
        return { error => "name is missing" };
    }
};

# delete a user
# curl -H "Content-Type: application/json" -X DELETE http://localhost:5000/api/user/1
# {"deleted":1}
del '/api/user/:id' => sub {
    my $params = request->params;
    if ( $params->{id} ) {
        if ( exists $users{ $params->{id} } ) {
            delete $users{ $params->{id} };
            return { deleted => 1 };
        }
        else {
            return { error => "unknown user" };
        }
    }
    else {
        return { error => "user id is missing" };
    }
};

# curl http://localhost:5000/user/1
# or
# curl -H "X-Requested-With: XMLHttpRequest" http://localhost:5000/user/1
get '/user/:id' => sub {
    my $params = request->params;
    my $user    = $users{ $params->{id} };
    my $result;
    if ( !$user ) {
        _render_user( { error => "unknown user" } );
    }
    else {
        _render_user($user);
    }
};

sub _render_user {
    my $result  = shift;
    if ( request->is_ajax ) {
        return $result;
    }
    else {
        template 'user.tt', $result;
    }
}

true;
