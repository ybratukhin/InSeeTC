#!/usr/bin/env php
<?php
/**
 * test case for inSee company.
 *
 * @link https://github.com/ybratukhin/InSeeTC
 * @copyright Copyright (c) 2020 Yury Bratuhin
 * @license MIT
 */

if (php_sapi_name() !== 'cli') {
    exit;
}

require __DIR__ . '/vendor/autoload.php';

class InitCommand extends Ahc\Cli\Input\Command
{
    public function __construct()
    {
        parent::__construct('', 'Use <owner/repo> param to get latest commit sha');

        $this->argument('<arg>', 'Repository name in owner/repo format')
            ->argument('[branch:master]', 'Branch name, master by default')
            ->option('-s --service', 'The service (git/bitbucket)')
            ->option('-u --user', 'The user')
            ->option('-p --password', 'The password')
            ->option('-t --token', 'The Personal access Token')
            ->usage(
                '<bold> $0</end> <comment>--service git --token api_token --user user_name --password user_password <owner/repo> [master]</end> ## details 1<eol/>' .
                '<bold> $0</end> <comment>-s git -t api_token -u user -p password <owner/repo> [master]</end> ## details 2<eol/>'
            );
    }

    public function execute($service, $token, $user, $password)
    {
        $io = $this->app()->io();
        if (preg_match("/(.*)\/(.*)/i", $this->arg, $matches)) {

            $owner = $matches[1];
            $repo =  $matches[2];

            // Here in dependency on $service we can use different clients.
            $client = new \Github\Client();

            // if we have auth option entered - then we can try to authenticate
            if (!empty($token) || !empty($user) ) {
                if (!empty($token)) {
                    $_user = $token;
                    $_password = '';
                    $_auth = Github\Client::AUTH_HTTP_TOKEN;
                } else {
                    $_user = $user;
                    $_password = (!empty($password)) ? $password : $io->promptHidden('Enter password');
                    $_auth =  Github\Client::AUTH_HTTP_PASSWORD;
                }
                $client->authenticate($_user, $_password, $_auth);
            } else {
                // in there is no credentials provided we can try to run query - if it's fails - we should authenticate
                try {
                    $client->api('repo')->show($owner, $repo);
                } catch (Exception $e) {
                    $io->write('Repository is private, please use user/password or personal access token', true);

                    $_ma = ['1' => 'user/password', '2' => 'token'];
                    $choice = $io->choice('Select auth method', $_ma, '1');
                    $io->greenBold("You selected: {$_ma[$choice]}", true);

                    if ($choice == 1) {
                        $_user = $io->prompt('Enter user');
                        $_password = $io->promptHidden('Enter password');
                        $_auth =  Github\Client::AUTH_HTTP_PASSWORD;
                    } else {
                        $_user = $io->prompt('Enter token');
                        $_password = '';
                        $_auth = Github\Client::AUTH_HTTP_TOKEN;
                    }
                    $client->authenticate($_user, $_password, $_auth);
                }
            }

            try {
                $commits = $client->api('repo')->commits()->all($owner, $repo, array('sha' => $this->branch));
                $io->write('Sha ' . $commits[0]['sha'], true);
            } catch (Github\Exception\TwoFactorAuthenticationRequiredException $e) {
                $io->write("Two factor authentication of type " . $e->getType() . " is required. Unfortunately this functionality not work. Try use personal access token.");
                // In theory after that, user should receive SMS and we can require input of it and next request will authenticate us
                // but I never received it.
                // $authorization = $client->api('authorizations')->create(array('note' => 'Required'), $code);
            }
        } else {
            $io->write('Repository name should be in owner/repo format', true);
        }
    }
}

$app = new Ahc\Cli\Application('App', 'v0.0.1');
$app->add(new InitCommand, '');
$app->logo('Developed by Yury B. for InSee Company');
$app->handle($_SERVER['argv']); // if argv[1] is `i` or `init` it executes InitCommand