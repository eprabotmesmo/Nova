#########################################################################
#  OpenKore - Commandline
#
#  This software is open source, licensed under the GNU General Public
#  License, version 2.
#  Basically, this means that you're allowed to modify and distribute
#  this software. However, if you distribute modified versions, you MUST
#  also distribute the source code.
#  See http://www.gnu.org/licenses/gpl.html for the full license.
#
#  $Revision$
#  $Id$
#
#########################################################################
##
# MODULE DESCRIPTION: Commandline input processing
#
# This module processes commandline input.

package Commands;

use strict;
use warnings;
no warnings qw(redefine uninitialized);
use Time::HiRes qw(time);
use utf8;

use Modules 'register';
use Globals;
use Log qw(message debug error warning);
use Misc;
use Network;
use Network::Send ();
use Settings;
use Plugins;
use Skill;
use Utils;
use Utils::Exceptions;
use AI;
use Task;
use Task::ErrorReport;
use Match;
use Translation;
use I18N qw(stringToBytes);
use Network::PacketParser qw(STATUS_STR STATUS_AGI STATUS_VIT STATUS_INT STATUS_DEX STATUS_LUK);

our %handlers;
our %completions;

undef %handlers;
undef %completions;

our %customCommands;


sub initHandlers {
	%handlers = (
	a					=> \&cmdAttack,
	achieve				=> \&cmdAchieve,
	ai					=> \&cmdAI,
	aiv					=> \&cmdAIv,
	al					=> \&cmdShopInfoSelf,
	as					=> \&cmdAttackStop,
	autobuy				=> \&cmdAutoBuy,
	autosell			=> \&cmdAutoSell,
	autostorage			=> \&cmdAutoStorage,
	auth				=> \&cmdAuthorize,
	bangbang			=> \&cmdBangBang,
	bingbing			=> \&cmdBingBing,
	bg					=> \&cmdChat,
	bl					=> \&cmdBuyerList,
	booking				=> \&cmdBooking,
	buy					=> \&cmdBuy,
	buyer				=> \&cmdBuyer,
	bs					=> \&cmdBuyShopInfoSelf,
	c					=> \&cmdChat,
	canceltransaction	=> \&cmdCancelTransaction,
	card				=> \&cmdCard,
	charselect			=> \&cmdCharSelect,
	chist				=> \&cmdChist,
	cil					=> \&cmdItemLogClear,
	clearlog			=> \&cmdChatLogClear,
	closeshop			=> \&cmdCloseShop,
	closebuyshop		=> \&cmdCloseBuyShop,
	conf				=> \&cmdConf,
	connect				=> \&cmdConnect,
	damage				=> \&cmdDamage,
	dead				=> \&cmdDeadTime,
	deal				=> \&cmdDeal,
	debug				=> \&cmdDebug,
	dl					=> \&cmdDealList,
	doridori			=> \&cmdDoriDori,
	drop				=> \&cmdDrop,
	dump				=> \&cmdDump,
	dumpnow				=> \&cmdDumpNow,
	e					=> \&cmdEmotion,
	eq					=> \&cmdEquip,
	eval				=> \&cmdEval,
	exp					=> \&cmdExp,
	falcon				=> \&cmdFalcon,
	friend				=> \&cmdFriend,
	g					=> \&cmdChat,
	getplayerinfo		=> \&cmdGetPlayerInfo,
	getcharname			=> \&cmdGetCharacterName,
	i					=> \&cmdInventory,
	identify			=> \&cmdIdentify,
	ignore				=> \&cmdIgnore,
	ihist				=> \&cmdIhist,
	il					=> \&cmdItemList,
	im					=> \&cmdUseItemOnMonster,
	ip					=> \&cmdUseItemOnPlayer,
	is					=> \&cmdUseItemOnSelf,
	kill				=> \&cmdKill,
	look				=> \&cmdLook,
	lookp				=> \&cmdLookPlayer,
	memo				=> \&cmdMemo,
	ml					=> \&cmdMonsterList,
	move				=> \&cmdMove,
	nl					=> \&cmdNPCList,
	openshop			=> \&cmdOpenShop,
	p					=> \&cmdChat,
	pl					=> \&cmdPlayerList,
	plugin				=> \&cmdPlugin,
	pm					=> \&cmdPrivateMessage,
	pml					=> \&cmdPMList,
	portals				=> \&cmdPortalList,
	quit				=> \&cmdQuit,
	rc					=> \&cmdReloadCode,
	rc2					=> \&cmdReloadCode2,
	reload				=> \&cmdReload,
	relog				=> \&cmdRelog,
	repair				=> \&cmdRepair,
	respawn				=> \&cmdRespawn,
	s					=> \&cmdStatus,
	sell				=> \&cmdSell,
	send				=> \&cmdSendRaw,
	sit					=> \&cmdSit,
	skills				=> \&cmdSkills,
	spells				=> \&cmdSpells,
	storage				=> \&cmdStorage,
	store				=> \&cmdStore,
	sl					=> \&cmdUseSkill,
	sm					=> \&cmdUseSkill,
	sp					=> \&cmdUseSkill,
	ss					=> \&cmdUseSkill,
	ssl					=> \&cmdUseSkill,
	ssp					=> \&cmdUseSkill,
	st					=> \&cmdStats,
	stand				=> \&cmdStand,
	stat_add			=> \&cmdStatAdd,
	switchconf			=> \&cmdSwitchConf,
	take				=> \&cmdTake,
	talk				=> \&cmdTalk,
	talknpc				=> \&cmdTalkNPC,
	tank				=> \&cmdTank,
	tele				=> \&cmdTeleport,
	testshop			=> \&cmdTestShop,
	timeout				=> \&cmdTimeout,
	uneq				=> \&cmdUnequip,
	vender				=> \&cmdVender,
	verbose				=> \&cmdVerbose,
	version				=> \&cmdVersion,
	vl					=> \&cmdVenderList,
	vs					=> \&cmdShopInfoSelf,
	warp				=> \&cmdWarp,
	weight				=> \&cmdWeight,
	where				=> \&cmdWhere,
	who					=> \&cmdWho,
	whoami				=> \&cmdWhoAmI,
	party				=> \&cmdParty,

	au					=> \&cmdAuction,	# see commands
	aua					=> \&cmdAuction,	# add item
	aur					=> \&cmdAuction,	# remove item
	auc					=> \&cmdAuction,	# create auction
	aue					=> \&cmdAuction,	# auction end
	aus					=> \&cmdAuction,	# search auction
	aub					=> \&cmdAuction,	# make bid
	aui					=> \&cmdAuction,	# info on buy/sell
	aud					=> \&cmdAuction,	# delete auction

	showeq				=> \&cmdShowEquip,
	cook				=> \&cmdCooking,

	north				=> \&cmdManualMove,
	south				=> \&cmdManualMove,
	east				=> \&cmdManualMove,
	west				=> \&cmdManualMove,
	northeast			=> \&cmdManualMove,
	northwest			=> \&cmdManualMove,
	southeast			=> \&cmdManualMove,
	southwest			=> \&cmdManualMove,
	captcha			   => \&cmdAnswerCaptcha,
	refineui			=> \&cmdRefineUI,

	# Skill Exchange Item
	cm					=> \&cmdExchangeItem,
	analysis			=> \&cmdExchangeItem,
	);
}

sub initCompletions {
	%completions = ();
}

### CATEGORY: Functions

##
# Commands::run(input)
# input: a command.
#
# Processes $input. See also <a href="http://openkore.sourceforge.net/docs.php">the user documentation</a>
# for a list of commands.
#
# Example:
# # Same effect as typing 's' in the console. Displays character status
# Commands::run("s");
sub run {
	my $input = shift;
	initHandlers() if (!%handlers);

	# Resolve command aliases
	my ($switch, $args) = split(/ +/, $input, 2);
	if (my $alias = $config{"alias_$switch"}) {
		$input = $alias;
		$input .= " $args" if defined $args;
	}

	# Remove trailing spaces from input
	$input =~ s/^\s+//;

	my @commands = split(';;', $input);
	# Loop through all of the commands...
	foreach my $command (@commands) {
		my ($switch, $args) = split(/ +/, $command, 2);
		my $handler;
		$handler = $customCommands{$switch}{callback} if ($customCommands{$switch});
		$handler = $handlers{$switch} if (!$handler && $handlers{$switch});

		if (($switch eq 'pause') && (!$cmdQueue) && AI::state != AI::AUTO && ($net->getState() == Network::IN_GAME)) {
			$cmdQueue = 1;
			$cmdQueueStartTime = time;
			if ($args > 0) {
				$cmdQueueTime = $args;
			} else {
				$cmdQueueTime = 1;
			}
			debug "Command queueing started\n", "ai";
		} elsif (($switch eq 'pause') && ($cmdQueue > 0)) {
			push(@cmdQueueList, $command);
		} elsif (($switch eq 'pause') && (AI::state != AI::AUTO || ($net->getState() != Network::IN_GAME))) {
			error T("Cannot use pause command now.\n");
		} elsif (($handler) && ($cmdQueue > 0) && (!defined binFind(\@cmdQueuePriority,$switch) && ($command ne 'cart') && ($command ne 'storage'))) {
			push(@cmdQueueList, $command);
		} elsif ($handler) {
			my %params;
			$params{switch} = $switch;
			$params{args} = $args;
			Plugins::callHook("Commands::run/pre", \%params);
			$handler->($switch, $args);
			Plugins::callHook("Commands::run/post", \%params);

		} else {
			my %params = ( switch => $switch, input => $command );
			Plugins::callHook('Command_post', \%params);
			if (!$params{return}) {
				error TF("Unknown command '%s'. Please read the documentation for a list of commands.\n"
						."http://openkore.com/index.php/Category:Console_Command\n", $switch);
			} else {
				return $params{return}
			}
		}
	}
	return 1;
}


##
# Commands::register([name, description, callback]...)
# Returns: an ID for use with Commands::unregister()
#
# Register new commands.
#
# Example:
# my $ID = Commands::register(
#     ["my_command", "My custom command's description", \&my_callback],
#     ["another_command", "Yet another command description", \&another_callback]
# );
# Commands::unregister($ID);
sub register {
	my @result;

	foreach my $cmd (@_) {
		my $name = $cmd->[0];
		my %item = (
			desc => $cmd->[1],
			callback => $cmd->[2]
		);
		$customCommands{$name} = \%item;
		push @result, $name;
	}
	return \@result;
}


##
# Commands::unregister(ID)
# ID: an ID returned by Commands::register()
#
# Unregisters a registered command.
sub unregister {
	my $ID = shift;

	foreach my $name (@{$ID}) {
		delete $customCommands{$name};
	}
}


sub complete {
	my $input = shift;
	my ($switch, $args) = split(/ +/, $input, 2);

	return if ($input eq '');
	initCompletions() if (!%completions);

	# Resolve command aliases
	if (my $alias = $config{"alias_$switch"}) {
		$input = $alias;
		$input .= " $args" if defined $args;
		($switch, $args) = split(/ +/, $input, 2);
	}

	my $completor;
	if ($completions{$switch}) {
		$completor = $completions{$switch};
	} else {
		$completor = \&defaultCompletor;
	}

	my ($last_arg_pos, $matches) = $completor->($switch, $input, 'c');
	if (@{$matches} == 1) {
		my $arg = $matches->[0];
		$arg = "\"$arg\"" if ($arg =~ / /);
		my $new = substr($input, 0, $last_arg_pos) . $arg;
		if (length($new) > length($input)) {
			return "$new ";
		} elsif (length($new) == length($input)) {
			return "$input ";
		}

	} elsif (@{$matches} > 1) {
		$interface->writeOutput("message", "\n" . join("\t", @{$matches}) . "\n", "info");

		## Find largest common prefix

		# Find item with smallest length
		my $smallest;
		foreach (@{$matches}) {
			if (!defined $smallest || length($_) < $smallest) {
				$smallest = length($_);
			}
		}

		my $commonStr;
		for (my $len = $smallest; $len >= 0; $len--) {
			my $first = lc(substr($matches->[0], 0, $len));
			my $common = 1;
			foreach (@{$matches}) {
				if ($first ne lc(substr($_, 0, $len))) {
					$common = 0;
					last;
				}
			}
			if ($common) {
				$commonStr = $first;
				last;
			}
		}

		my $new = substr($input, 0, $last_arg_pos) . $commonStr;
		return $new if (length($new) > length($input));
	}
	return $input;
}

sub cmdParty {
	my (undef, $args) = @_;
	my ($arg1, $arg2) = parseArgs($args, 2);

	if (!$net || $net->getState() != Network::IN_GAME) {
		error TF("You must be logged in the game to use this command\n");
	} elsif (!$char) {
		error T("Error in function 'party' (Party Functions)\n" .
			"Party info not available yet\n");
	} elsif (!$char->{party}{joined}) {
		if ($arg1 eq "create") {
			if ($arg2 eq "") {
				error T("Syntax Error in function 'party create' (Organize Party)\n" .
					"Usage: party create <party name>\n");
			} else {
				$messageSender->sendPartyOrganize($arg2);
			}
		} elsif ($arg1 eq "join") {
			if ($arg2 ne "1" && $arg2 ne "0") {
				error T("Syntax Error in function 'party join' (Accept/Deny Party Join Request)\n" .
					"Usage: party join <flag>\n");
			} elsif ($incomingParty{ID} eq "") {
				error T("Error in function 'party join' (Join/Request to Join Party)\n" .
					"Can't accept/deny party request - no incoming request.\n");
			} else {
				if ($incomingParty{ACK} eq '02C7') {
					$messageSender->sendPartyJoinRequestByNameReply($incomingParty{ID}, $arg2);
				} else {
					$messageSender->sendPartyJoin($incomingParty{ID}, $arg2);
				}
				undef %incomingParty;
			}
		} else {
			error T("Error in function 'party' (Party Functions)\n" .
				"You're not in a party.\n");
		}
	} elsif ($char->{party}{joined} && ($arg1 eq "create" || $arg1 eq "join")) {
		error T("Error in function 'party' (Party Functions)\n" .
			"You're already in a party.\n");
	} elsif ($arg1 eq "" || $arg1 eq "info") {
		my $msg = center(T(" Party Information "), 79, '-') ."\n".
			TF("Party name: %s\n" . 
			"EXP Take: %s       Item Take: %s       Item Division: %s\n\n".
			"#    Name                   Map           Coord     Online  HP\n",
			$char->{'party'}{'name'},
			($char->{party}{share}) ? T("Even") : T("Individual"),
			($char->{party}{itemPickup}) ? T("Even") : T("Individual"),
			($char->{party}{itemDivision}) ? T("Even") : T("Individual"));
		for (my $i = 0; $i < @partyUsersID; $i++) {
			next if ($partyUsersID[$i] eq "");
			my $coord_string = "";
			my $hp_string = "";
			my $name_string = $char->{'party'}{'users'}{$partyUsersID[$i]}{'name'};
			my $admin_string = ($char->{'party'}{'users'}{$partyUsersID[$i]}{'admin'}) ? T("A") : "";
			my $online_string;
			my $map_string;

			if ($partyUsersID[$i] eq $accountID) {
				# Translation Comment: Is the party user on list online?
				$online_string = T("Yes");
				($map_string) = $field->name;
				$coord_string = $char->{'pos'}{'x'}. ", ".$char->{'pos'}{'y'};
				$hp_string = $char->{'hp'}."/".$char->{'hp_max'}
						." (".int($char->{'hp'}/$char->{'hp_max'} * 100)
						."%)";
			} else {
				$online_string = ($char->{'party'}{'users'}{$partyUsersID[$i]}{'online'}) ? T("Yes") : T("No");
				($map_string) = $char->{'party'}{'users'}{$partyUsersID[$i]}{'map'} =~ /([\s\S]*)\.gat/;
				$coord_string = $char->{'party'}{'users'}{$partyUsersID[$i]}{'pos'}{'x'}
					. ", ".$char->{'party'}{'users'}{$partyUsersID[$i]}{'pos'}{'y'}
					if ($char->{'party'}{'users'}{$partyUsersID[$i]}{'pos'}{'x'} ne ""
						&& $char->{'party'}{'users'}{$partyUsersID[$i]}{'online'});
				$hp_string = $char->{'party'}{'users'}{$partyUsersID[$i]}{'hp'}."/".$char->{'party'}{'users'}{$partyUsersID[$i]}{'hp_max'}
					." (".int($char->{'party'}{'users'}{$partyUsersID[$i]}{'hp'}/$char->{'party'}{'users'}{$partyUsersID[$i]}{'hp_max'} * 100)
					."%)" if ($char->{'party'}{'users'}{$partyUsersID[$i]}{'hp_max'} && $char->{'party'}{'users'}{$partyUsersID[$i]}{'online'});
			}
			$msg .= swrite(
				"@< @ @<<<<<<<<<<<<<<<<<<<<< @<<<<<<<<<<<< @<<<<<<<  @<<     @<<<<<<<<<<<<<<<<<<",
				[$i, $admin_string, $name_string, $map_string, $coord_string, $online_string, $hp_string]);
		}
		$msg .= ('-'x79) . "\n";
		message $msg, "list";

	} elsif ($arg1 eq "leave") {
		$messageSender->sendPartyLeave();
	# party leader specific commands
	} elsif ($arg1 eq "share" || $arg1 eq "shareitem" || $arg1 eq "shareauto" || $arg1 eq "sharediv" || $arg1 eq "kick" || $arg1 eq "leader" || $arg1 eq "request") {
		if ($arg2 ne "") {
			my $party_admin;
			# check if we are the party leader before using leader specific commands.
			for (my $i = 0; $i < @partyUsersID; $i++) {
				if (($char->{'party'}{'users'}{$partyUsersID[$i]}{'admin'}) && ($char->{'party'}{'users'}{$partyUsersID[$i]}{'name'} eq $char->name)){
					debug T("You are the party leader.\n"), "info";
					$party_admin = 1;
					last;
				}
			}
			
			if (!$party_admin) {
				error TF("Error in function 'party %s'\n" .
					"You must be the party leader in order to use this !\n", $arg1);
				return;
			}
		}
		
		if ($arg1 eq "request") {
			if ($arg2 =~ /\D/ || $args =~ /".*"/) {
				message TF("Requesting player %s to join your party.\n", $arg2);
				$messageSender->sendPartyJoinRequestByName($arg2);
			} else {
				if ($playersID[$arg2] eq "") {
					error TF("Error in function 'party request' (Request to Join Party)\n" .
						"Can't request to join party - player %s does not exist.\n", $arg2);
				} else {
					$messageSender->sendPartyJoinRequest($playersID[$arg2]);
				}
			}
		} elsif ($arg1 eq "share"){
			if ($arg2 ne "1" && $arg2 ne "0") {
				if ($arg2 eq "") {
					message TF("Party EXP is set to '%s Take'\n", ($char->{party}{share}) ? T("Even") : T("Individual"));
				} else {
					error T("Syntax Error in function 'party share' (Set Party Share EXP)\n" .
						"Usage: party share <flag>\n");
				}
			} else {
				$messageSender->sendPartyOption($arg2, $char->{party}{itemPickup}, $char->{party}{itemDivision});
				$char->{party}{shareForcedByCommand} = 1;
			}
		} elsif ($arg1 eq "shareitem") {
			if ($arg2 ne "1" && $arg2 ne "0") {
				if ($arg2 eq "") {
					message TF("Party item is set to '%s Take'\n", ($char->{party}{itemPickup}) ? T("Even") : T("Individual"));
				} else {
					error T("Syntax Error in function 'party shareitem' (Set Party Share Item)\n" .
						"Usage: party shareitem <flag>\n");
				}
			} else {
				$messageSender->sendPartyOption($char->{party}{share}, $arg2, $char->{party}{itemDivision});
				$char->{party}{shareForcedByCommand} = 1;
			}
		} elsif ($arg1 eq "sharediv") {
			if ($arg2 ne "1" && $arg2 ne "0") {
				if ($arg2 eq "") {
					message TF("Party item division is set to '%s Take'\n", ($char->{party}{itemDivision}) ? T("Even") : T("Individual"));
				} else {
					error T("Syntax Error in function 'party sharediv' (Set Party Item Division)\n" .
						"Usage: party sharediv <flag>\n");
				}
			} else {
				$messageSender->sendPartyOption($char->{party}{share}, $char->{party}{itemPickup}, $arg2);
				$char->{party}{shareForcedByCommand} = 1;
			}
		} elsif ($arg1 eq "shareauto") {
			$messageSender->sendPartyOption($config{partyAutoShare}, $config{partyAutoShareItem}, $config{partyAutoShareItemDiv});
			$char->{party}{shareForcedByCommand} = undef;
		} elsif ($arg1 eq "kick") {
			if ($arg2 eq "") {
				error T("Syntax Error in function 'party kick' (Kick Party Member)\n" .
					"Usage: party kick <party member>\n");
			} elsif ($arg2 =~ /\D/ || $args =~ /".*"/) {
				my $found;
				foreach (@partyUsersID) {
					if ($char->{'party'}{'users'}{$_}{'name'} eq $arg2) {
						$messageSender->sendPartyKick($_, $arg2);
						$found = 1;
						last;
					}
				}
				
				if (!$found) {
					error TF("Error in function 'party kick' (Kick Party Member)\n" .
						"Can't kick member - member %s doesn't exist.\n", $arg2);
				}
			} else {
				if ($partyUsersID[$arg2] eq "") {
					error TF("Error in function 'party kick' (Kick Party Member)\n" .
						"Can't kick member - member %s doesn't exist.\n", $arg2);
				} else {
					$messageSender->sendPartyKick($partyUsersID[$arg2], $char->{'party'}{'users'}{$partyUsersID[$arg2]}{'name'});
				}
			}
		} elsif ($arg1 eq "leader") {
			if ($arg2 eq "") {
				error T("Syntax Error in function 'party leader' (Change Party Leader)\n" .
					"Usage: party leader <party member>\n");
			} elsif ($arg2 =~ /\D/ || $args =~ /".*"/) {
				my $found;
				foreach (@partyUsersID) {
					if ($char->{'party'}{'users'}{$_}{'name'} eq $arg2) {
						$messageSender->sendPartyLeader($_);
						$found = 1;
						last;
					}
				}
				
				if (!$found) {
					error TF("Error in function 'party leader' (Change Party Leader)\n" .
						"Can't change party leader - member %s doesn't exist.\n", $arg2);
				}
			} else {
				if ($partyUsersID[$arg2] eq "") {
					error TF("Error in function 'party leader' (Change Party Leader)\n" .
						"Can't change party leader - member %s doesn't exist.\n", $arg2);
				} else {
					$messageSender->sendPartyLeader($partyUsersID[$arg2]);
				}
			}
		}
	} else {
		error T("Syntax Error in function 'party' (Party Management)\n" .
			"Usage: party [<info|create|join|request|leave|share|shareitem|sharediv|shareauto|kick|leader>]\n");
	}
}

sub completePlayerName {
	my $arg = quotemeta shift;
	my @matches;
	foreach (@playersID) {
		next if (!$_);
		if ($players{$_}{name} =~ /^$arg/i) {
			push @matches, $players{$_}{name};
		}
	}
	return @matches;
}

sub defaultCompletor {
	my $switch = shift;
	my $last_arg_pos;
	my @args = parseArgs(shift, undef, undef, \$last_arg_pos);
	my @matches;

	my $arg = $args[$#args];
	@matches = completePlayerName($arg);
	return ($last_arg_pos, \@matches);
}


##################################
### CATEGORY: Commands


sub cmdAI {
	my (undef, $args) = @_;
	$args =~ s/ .*//;

	# Clear AI
	@cmdQueueList = ();
	$cmdQueue = 0;
	if ($args eq 'clear') {
		AI::clear;
		$taskManager->stopAll() if defined $taskManager;
		delete $ai_v{temp};
		if ($char) {
			undef $char->{dead};
		}
		message T("AI sequences cleared\n"), "success";

	} elsif ($args eq 'print') {
		# Display detailed info about current AI sequence
		my $msg = center(T(" AI Sequence "), 50, '-') ."\n";
		my $index = 0;
		foreach (@ai_seq) {
			$msg .= ("$index: $_ " . dumpHash(\%{$ai_seq_args[$index]}) . "\n\n");
			$index++;
		}
		$msg .= ('-'x50) . "\n";
		message $msg, "list";

	} elsif ($args eq 'ai_v') {
		message dumpHash(\%ai_v) . "\n", "list";

	} elsif ($args eq 'on' || $args eq 'auto') {
		# Set AI to auto mode
		if (AI::state == AI::AUTO) {
			message T("AI is already set to auto mode\n"), "success";
		} else {
			AI::state(AI::AUTO);
			message T("AI set to auto mode\n"), "success";
		}
	} elsif ($args eq 'manual') {
		# Set AI to manual mode
		if (AI::state == AI::MANUAL) {
			message T("AI is already set to manual mode\n"), "success";
		} else {
			AI::state(AI::MANUAL);
			message T("AI set to manual mode\n"), "success";
		}
	} elsif ($args eq 'off') {
		# Turn AI off
		if (AI::state == AI::OFF) {
			message T("AI is already off\n"), "success";
		} else {
			AI::state(AI::OFF);
			message T("AI turned off\n"), "success";
		}

	} elsif ($args eq '') {
		# Toggle AI
		if (AI::state == AI::AUTO) {
			AI::state(AI::OFF);
			message T("AI turned off\n"), "success";
		} elsif (AI::state == AI::OFF) {
			AI::state(AI::MANUAL);
			message T("AI set to manual mode\n"), "success";
		} elsif (AI::state == AI::MANUAL) {
			AI::state(AI::AUTO);
			message T("AI set to auto mode\n"), "success";
		}

	} else {
		error T("Syntax Error in function 'ai' (AI Commands)\n" .
			"Usage: ai [ clear | print | ai_v | auto | manual | off ]\n");
	}
}

sub cmdAIv {
	# Display current AI sequences
	my $on;
	if (AI::state == AI::OFF) {
		message TF("ai_seq (off) = %s\n", "@ai_seq"), "list";
	} elsif (AI::state == AI::MANUAL) {
		message TF("ai_seq (manual) = %s\n", "@ai_seq"), "list";
	} elsif (AI::state == AI::AUTO) {
		message TF("ai_seq (auto) = %s\n", "@ai_seq"), "list";
	}
	message T("solution\n"), "list" if (AI::args->{'solution'});
	message TF("Active tasks: %s\n", (defined $taskManager) ? $taskManager->activeTasksString() : ''), "info";
	message TF("Inactive tasks: %s\n", (defined $taskManager) ? $taskManager->inactiveTasksString() : ''), "info";
}

sub cmdAttack {
	my (undef, $arg1) = @_;
	if ($arg1 =~ /^\d+$/) {
		if ($monstersID[$arg1] eq "") {
			error TF("Error in function 'a' (Attack Monster)\n" .
				"Monster %s does not exist.\n", $arg1);
		} else {
			main::attack($monstersID[$arg1]);
		}
	} elsif ($arg1 eq "no") {
		configModify("attackAuto", 1);

	} elsif ($arg1 eq "yes") {
		configModify("attackAuto", 2);

	} else {
		error T("Syntax Error in function 'a' (Attack Monster)\n" .
			"Usage: attack <monster # | no | yes >\n");
	}
}

sub cmdAttackStop {
	my $index = AI::findAction("attack");
	if ($index ne "") {
		my $args = AI::args($index);
		my $monster = Actor::get($args->{ID});
		if ($monster) {
			$monster->{ignore} = 1;
			$char->sendAttackStop;
			message TF("Stopped attacking %s (%s)\n",
				$monster->{name}, $monster->{binID}), "success";
			AI::clear("attack");
		}
	}
}

sub cmdAuthorize {
	my (undef, $args) = @_;
	my ($arg1, $arg2) = $args =~ /^([\s\S]*) ([\s\S]*?)$/;
	if ($arg1 eq "" || ($arg2 ne "1" && $arg2 ne "0")) {
		error T("Syntax Error in function 'auth' (Overall Authorize)\n" .
			"Usage: auth <username> <flag>\n");
	} else {
		auth($arg1, $arg2);
	}
}

sub cmdAutoBuy {
	message T("Initiating auto-buy.\n");
	AI::queue("buyAuto");
}

sub cmdAutoSell {
	my (undef, $arg) = @_;
	if ($arg eq 'simulate' || $arg eq 'test' || $arg eq 'debug') {
		# Simulate list of items to sell
		my @sellItems;
		my $msg = center(T(" Items to sell (simulation) "), 50, '-') ."\n".
				T("Amount  Item Name\n");
		for my $item (@{$char->inventory}) {
			next if ($item->{unsellable});
			my $control = items_control($item->{name},$item->{nameID});
			if ($control->{'sell'} && $item->{'amount'} > $control->{keep}) {
				my %obj;
				$obj{index} = $item->{ID};
				$obj{amount} = $item->{amount} - $control->{keep};
				my $item_name = $item->{name};
				$item_name .= ' (if unequipped)' if ($item->{equipped});
				$msg .= swrite(
						"@>>> x  @<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<",
						[$item->{amount}, $item_name]);
			}
		}
		$msg .= ('-'x50) . "\n";
		message ($msg, "list");
	} elsif (!$arg) {
		message T("Initiating auto-sell.\n");
		AI::queue("sellAuto");
	}
}

sub cmdAutoStorage {
	message T("Initiating auto-storage.\n");
	AI::queue("storageAuto");
}

sub cmdBangBang {
	if (!$net || $net->getState() != Network::IN_GAME) {
		error TF("You must be logged in the game to use this command '%s'\n", shift);
		return;
	}
	my $bodydir = $char->{look}{body} - 1;
	$bodydir = 7 if ($bodydir == -1);
	$messageSender->sendLook($bodydir, $char->{look}{head});
}

sub cmdBingBing {
	if (!$net || $net->getState() != Network::IN_GAME) {
		error TF("You must be logged in the game to use this command '%s'\n", shift);
		return;
	}
	my $bodydir = ($char->{look}{body} + 1) % 8;
	$messageSender->sendLook($bodydir, $char->{look}{head});
}

sub cmdBuy {
	if (!$net || $net->getState() != Network::IN_GAME) {
		error TF("You must be logged in the game to use this command '%s'\n", shift);
		return;
	}

	my (undef, $args) = @_;
	my @bulkitemlist;

	foreach (split /\,/, $args) {
		my($index,$amount) = $_ =~ /^\s*(\d+)\s*(\d*)\s*$/;

		if ($index eq "") {
			error T("Syntax Error in function 'buy' (Buy Store Item)\n" .
				"Usage: buy <item #> [<amount>][, <item #> [<amount>]]...\n");
			return;

		} elsif (!$storeList->get($index)) {
			error TF("Error in function 'buy' (Buy Store Item)\n" .
				"Store Item %s does not exist.\n", $index);
			return;

		} elsif ($amount eq "" || $amount <= 0) {
			$amount = 1;
		}

		my $itemID = $storeList->get($index)->{nameID};
		push (@bulkitemlist,{itemID  => $itemID, amount => $amount});
	}

	completeNpcBuy(\@bulkitemlist);
}

sub cmdCard {
	if (!$net || $net->getState() != Network::IN_GAME) {
		error TF("You must be logged in the game to use this command '%s'\n", shift);
		return;
	}
	my (undef, $input) = @_;
	my ($arg1) = $input =~ /^(\w+)/;
	my ($arg2) = $input =~ /^\w+ (\d+)/;
	my ($arg3) = $input =~ /^\w+ \d+ (\d+)/;

	if ($arg1 eq "mergecancel") {
		if (!defined $messageSender) {
			error T("Error in function 'bingbing' (Change look direction)\n" .
				"Can't use command while not connected to server.\n");
		} elsif ($cardMergeIndex ne "") {
			undef $cardMergeIndex;
			$messageSender->sendCardMerge(-1, -1);
			message T("Cancelling card merge.\n");
		} else {
			error T("Error in function 'card mergecancel' (Cancel a card merge request)\n" .
				"You are not currently in a card merge session.\n");
		}
	} elsif ($arg1 eq "mergelist") {
		# FIXME: if your items change order or are used, this list will be wrong
		if (@cardMergeItemsID) {
			my $msg = center(T(" Card Merge Candidates "), 50, '-') ."\n";
			foreach my $card (@cardMergeItemsID) {
				next if $card eq "" || !$char->inventory->get($card);
				$msg .= swrite(
					"@<<< @<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<",
					[$card, $char->inventory->get($card)]);
			}
			$msg .= ('-'x50) . "\n";
			message $msg, "list";
		} else {
			error T("Error in function 'card mergelist' (List availible card merge items)\n" .
				"You are not currently in a card merge session.\n");
		}
	} elsif ($arg1 eq "merge") {
		if ($arg2 =~ /^\d+$/) {
			my $found = binFind(\@cardMergeItemsID, $arg2);
			if (defined $found) {
				$messageSender->sendCardMerge($char->inventory->get($cardMergeIndex)->{ID},
					$char->inventory->get($arg2)->{ID});
			} else {
				if ($cardMergeIndex ne "") {
					error TF("Error in function 'card merge' (Finalize card merging onto item)\n" .
						"There is no item %s in the card mergelist.\n", $arg2);
				} else {
					error T("Error in function 'card merge' (Finalize card merging onto item)\n" .
						"You are not currently in a card merge session.\n");
				}
			}
		} else {
			error T("Syntax Error in function 'card merge' (Finalize card merging onto item)\n" .
				"Usage: card merge <item number>\n" .
				"<item number> - Merge item number. Type 'card mergelist' to get number.\n");
		}
	} elsif ($arg1 eq "use") {
		if ($arg2 =~ /^\d+$/) {
			if ($char->inventory->get($arg2)) {
				$cardMergeIndex = $arg2;
				$messageSender->sendCardMergeRequest($char->inventory->get($cardMergeIndex)->{ID});
				message TF("Sending merge list request for %s...\n",
					$char->inventory->get($cardMergeIndex)->{name});
			} else {
				error TF("Error in function 'card use' (Request list of items for merging with card)\n" .
					"Card %s does not exist.\n", $arg2);
			}
		} else {
			error T("Syntax Error in function 'card use' (Request list of items for merging with card)\n" .
				"Usage: card use <item number>\n" .
				"<item number> - Card inventory number. Type 'i' to get number.\n");
		}
	} elsif ($arg1 eq "list") {
		my $msg = center(T(" Card List "), 50, '-') ."\n";
		for my $item (@{$char->inventory}) {
			if ($item->mergeable) {
				my $display = "$item->{name} x $item->{amount}";
				$msg .= swrite(
					"@<<< @<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<",
					[$item->{binID}, $display]);
			}
		}
		$msg .= ('-'x50) . "\n";
		message $msg, "list";
	} elsif ($arg1 eq "forceuse") {
		if (!$char->inventory->get($arg2)) {
			error TF("Error in function 'arrowcraft forceuse #' (Create Arrows)\n" .
				"You don't have item %s in your inventory.\n", $arg2);
		} elsif (!$char->inventory->get($arg3)) {
			error TF("Error in function 'arrowcraft forceuse #' (Create Arrows)\n" .
				"You don't have item %s in your inventory.\n"), $arg3;
		} else {
			$messageSender->sendCardMerge($char->inventory->get($arg2)->{ID},
				$char->inventory->get($arg3)->{ID});
		}
	} else {
		error T("Syntax Error in function 'card' (Card Compounding)\n" .
			"Usage: card <use|mergelist|mergecancel|merge>\n");
	}
}

sub cmdCart_desc {
	my $arg = shift;
	if (!($arg =~ /\d+/)) {
		error TF("Syntax Error in function 'cart desc' (Show Cart Item Description)\n" .
			"'%s' is not a valid cart item number.\n", $arg);
	} else {
		my $item = $char->cart->get($arg);
		if (!$item) {
			error TF("Error in function 'cart desc' (Show Cart Item Description)\n" .
				"Cart Item %s does not exist.\n", $arg);
		} else {
			printItemDesc($item->{nameID});
		}
	}
}

sub cmdCart_list {
	my $type = shift;
	message "$type\n";

	my @useable;
	my @equipment;
	my @non_useable;
	my ($i, $display, $index);
	
	for my $item (@{$char->cart}) {
		if ($item->usable) {
			push @useable, $item->{binID};
		} elsif ($item->equippable) {
			my %eqp;
			$eqp{index} = $item->{ID};
			$eqp{binID} = $item->{binID};
			$eqp{name} = $item->{name};
			$eqp{amount} = $item->{amount};
			$eqp{identified} = " -- " . T("Not Identified") if !$item->{identified};
			$eqp{type} = $itemTypes_lut{$item->{type}};
			push @equipment, \%eqp;
		} else {
			push @non_useable, $item->{binID};
		}
	}

	my $msg = center(T(" Cart "), 50, '-') ."\n".
			T("#  Name\n");

	if (!$type || $type eq 'u') {
		$msg .= T("-- Usable --\n");
		for (my $i = 0; $i < @useable; $i++) {
			$index = $useable[$i];
			my $item = $char->cart->get($index);
			$display = $item->{name};
			$display .= " x $item->{amount}";
			$msg .= swrite(
				"@<<< @<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<",
				[$index, $display]);
		}
	}

	if (!$type || $type eq 'eq') {
		$msg .= T("\n-- Equipment --\n");
		foreach my $item (@equipment) {
			## altered to allow for Arrows/Ammo which will are stackable equip.
			$display = sprintf("%-3d  %s (%s)", $item->{binID}, $item->{name}, $item->{type});
			$display .= " x $item->{amount}" if $item->{amount} > 1;
			$display .= $item->{identified};
			$msg .= sprintf("%-57s\n", $display);
		}
	}

	if (!$type || $type eq 'nu') {
		$msg .= T("\n-- Non-Usable --\n");
		for (my $i = 0; $i < @non_useable; $i++) {
			$index = $non_useable[$i];
			my $item = $char->cart->get($index);
			$display = $item->{name};
			$display .= " x $item->{amount}";
			$msg .= swrite(
				"@<<< @<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<",
				[$index, $display]);
		}
	}

	$msg .= TF("\nCapacity: %d/%d  Weight: %d/%d\n",
			$char->cart->items, $char->cart->items_max, $char->cart->{weight}, $char->cart->{weight_max}).
			('-'x50) . "\n";
	message $msg, "list";
}

sub cmdCart_add {
	my $items = shift;

	my ( $name, $amount );
	if ( $items =~ /^[^"'].* .+$/ ) {
		# Backwards compatibility: "cart add Empty Bottle 1" still works.
		( $name, $amount ) = $items =~ /^(.*?)(?: (\d+))?$/;
	} else {
		( $name, $amount ) = parseArgs( $items );
	}
	my @items = $char->inventory->getMultiple( $name );
	if ( !@items ) {
		error TF( "Inventory item '%s' does not exist.\n", $name );
		return;
	}

	transferItems( \@items, $amount, 'inventory' => 'cart' );
}

sub cmdCart_get {
	my $items = shift;

	my ( $name, $amount );
	if ( $items =~ /^[^"'].* .+$/ ) {
		# Backwards compatibility: "cart get Empty Bottle 1" still works.
		( $name, $amount ) = $items =~ /^(.*?)(?: (\d+))?$/;
	} else {
		( $name, $amount ) = parseArgs( $items );
	}
	my @items = $char->cart->getMultiple( $name );
	if ( !@items ) {
		error TF( "Cart item '%s' does not exist.\n", $name );
		return;
	}

	transferItems( \@items, $amount, 'cart' => 'inventory' );
}

sub cmdCharSelect {
	my (undef,$arg1) = @_;
	if (!$net || $net->getState() != Network::IN_GAME) {
		error TF("You must be logged in the game to use this command '%s'\n", shift);
		return;
	}
	if($arg1 =~ "1"){
		configModify("char",'');
	}
	Log::initLogFiles();
	$messageSender->sendRestart(1);
}

# chat, party chat, guild chat, battlegrounds chat
sub cmdChat {
	my ($command, $arg1) = @_;

	if (!$net || $net->getState() != Network::IN_GAME) {
		error TF("You must be logged in the game to use this command '%s'\n", $command);
		return;
	}

	if ($arg1 eq "") {
		error TF("Syntax Error in function '%1\$s' (Chat)\n" .
			"Usage: %1\$s <message>\n", $command);
	} else {
		sendMessage($messageSender, $command, $arg1);
	}
}

sub cmdChatLogClear {
	chatLog_clear();
	message T("Chat log cleared.\n"), "success";
}

sub cmdChist {
	# Display chat history
	my (undef, $args) = @_;
	$args = 5 if ($args eq "");
	if (!($args =~ /^\d+$/)) {
		error T("Syntax Error in function 'chist' (Show Chat History)\n" .
			"Usage: chist [<number of entries #>]\n");
	} elsif (open(CHAT, "<:utf8", $Settings::chat_log_file)) {
		my @chat = <CHAT>;
		close(CHAT);
		my $msg = center(T(" Chat History "), 79, '-') ."\n";
		my $i = @chat - $args;
		$i = 0 if ($i < 0);
		for (; $i < @chat; $i++) {
			$msg .= $chat[$i];
		}
		$msg .= ('-'x79) . "\n";
		message $msg, "list";
	} else {
		error TF("Unable to open %s\n", $Settings::chat_log_file);
	}
}

sub cmdCloseShop {
	if (!$net || $net->getState() != Network::IN_GAME) {
		error TF("You must be logged in the game to use this command '%s'\n", shift);
		return;
	}
	main::closeShop();
}

sub cmdCloseBuyShop {
	if (!$net || $net->getState() != Network::IN_GAME) {
		error TF("You must be logged in the game to use this command '%s'\n", shift);
		return;
	}
	$messageSender->sendCloseBuyShop();
	message T("Buying shop closed.\n", "BuyShop");
}

sub cmdConf {
	my (undef, $args) = @_;
	my ( $force, $arg1, $arg2 ) = $args =~ /^(-f\s+)?(\S+)\s*(.*)$/;

	# Basic Support for "label" in blocks. Thanks to "piroJOKE"
	if ($arg1 =~ /\./) {
		$arg1 =~ s/\.+/\./; # Filter Out Unnececary dot's
		my ($label, $param) = split /\./, $arg1, 2; # Split the label form parameter
		# This line is used for debug
		# message TF("Params label '%s' param '%s' arg1 '%s' arg2 '%s'\n", $label, $param, $arg1, $arg2), "info";
		foreach (%config) {
			if ($_ =~ /_\d+_label/){ # we only need those blocks witch have labels
				if ($config{$_} eq $label) {
					my ($real_key, undef) = split /_label/, $_, 2;
					# "<label>.block" param support. Thanks to "vit"
					if ($param ne "block") {
						$real_key .= "_";
						$real_key .= $param;
					}
					$arg1 = $real_key;
					last;
				};
			};
		};
	};

	if ($arg1 eq "") {
		error T("Syntax Error in function 'conf' (Change a Configuration Key)\n");
		error T("Usage: conf [-f] <variable> [<value>|none]\n");
		error T("  -f  force variable to be set, even if it does not already exist in config.txt\n");

	} elsif ($arg1 =~ /\*/) {
		my $pat = $arg1;
		$pat =~ s/\*/.*/gso;
		my @keys = grep {/$pat/i} sort keys %config;
		error TF( "Config variables matching %s do not exist\n", $arg1 ) if !@keys;
		message TF( "Config '%s' is %s\n", $_, defined $config{$_} ? $config{$_} : 'not set' ), "info" foreach @keys;

	} elsif (!exists $config{$arg1} && !$force) {
		error TF("Config variable %s doesn't exist\n", $arg1);

	} elsif ($arg2 eq "") {
		my $value = $config{$arg1};
		if ($arg1 =~ /password/i) {
			message TF("Config '%s' is not displayed\n", $arg1), "info";
		} else {
			if (defined $value) {
				message TF("Config '%s' is %s\n", $arg1, $value), "info";
			} else {
				message TF("Config '%s' is not set\n", $arg1), "info";
			}
		}

	} else {
		undef $arg2 if ($arg2 eq "none");
		Plugins::callHook('Commands::cmdConf', {
			key => $arg1,
			val => \$arg2
		});
		configModify($arg1, $arg2);
		Log::initLogFiles();
	}
}

sub cmdConnect {
	$Settings::no_connect = 0;
}

sub cmdDamage {
	my (undef, $args) = @_;

	if ($args eq "") {
		my $total = 0;
		message T("Damage Taken Report:\n"), "list";
		message(sprintf("%-40s %-20s %-10s\n", 'Name', 'Skill', 'Damage'), "list");
		for my $monsterName (sort keys %damageTaken) {
			my $monsterHref = $damageTaken{$monsterName};
			for my $skillName (sort keys %{$monsterHref}) {
				message sprintf("%-40s %-20s %10d\n", $monsterName, $skillName, $monsterHref->{$skillName}), "list";
				$total += $monsterHref->{$skillName};
			}
		}
		message TF("Total Damage Taken: %s\n", $total), "list";
		message T("End of report.\n"), "list";

	} elsif ($args eq "reset") {
		undef %damageTaken;
		message T("Damage Taken Report reset.\n"), "success";
	} else {
		error T("Syntax error in function 'damage' (Damage Report)\n" .
			"Usage: damage [reset]\n");
	}
}

sub cmdDeal {
	if (!$net || $net->getState() != Network::IN_GAME) {
		error TF("You must be logged in the game to use this command '%s'\n", shift);
		return;
	}

	my (undef, $args) = @_;
	my @arg = parseArgs( $args );

	if ( $arg[0] && $arg[0] !~ /^(\d+|no|add)$/ ) {
		my ( $partner ) = grep { $_->name eq $arg[0] } @$playersList;
		if ( !$partner ) {
			error TF( "Unknown player [%s]. Player not nearby?\n", $arg[0] );
			return;
		}
		$arg[0] = $partner->{binID};
	}

	if (%currentDeal && $arg[0] =~ /\d+/) {
		error T("Error in function 'deal' (Deal a Player)\n" .
			"You are already in a deal\n");
	} elsif (%incomingDeal && $arg[0] =~ /\d+/) {
		error T("Error in function 'deal' (Deal a Player)\n" .
			"You must first cancel the incoming deal\n");
	} elsif ($arg[0] =~ /\d+/ && !$playersID[$arg[0]]) {
		error TF("Error in function 'deal' (Deal a Player)\n" .
			"Player %s does not exist\n", $arg[0]);
	} elsif ($arg[0] =~ /\d+/) {
		my $ID = $playersID[$arg[0]];
		my $player = Actor::get($ID);
		message TF("Attempting to deal %s\n", $player);
		deal($player);

	} elsif ($arg[0] eq "no" && !%incomingDeal && !%outgoingDeal && !%currentDeal) {
		error T("Error in function 'deal' (Deal a Player)\n" .
			"There is no incoming/current deal to cancel\n");
	} elsif ($arg[0] eq "no" && (%incomingDeal || %outgoingDeal)) {
		$messageSender->sendDealReply(4);
	} elsif ($arg[0] eq "no" && %currentDeal) {
		$messageSender->sendCurrentDealCancel();

	} elsif ($arg[0] eq "" && !%incomingDeal && !%currentDeal) {
		error T("Error in function 'deal' (Deal a Player)\n" .
			"There is no deal to accept\n");
	} elsif ($arg[0] eq "" && $currentDeal{'you_finalize'} && !$currentDeal{'other_finalize'}) {
		error TF("Error in function 'deal' (Deal a Player)\n" .
			"Cannot make the trade - %s has not finalized\n", $currentDeal{'name'});
	} elsif ($arg[0] eq "" && $currentDeal{'final'}) {
		error T("Error in function 'deal' (Deal a Player)\n" .
			"You already accepted the final deal\n");
	} elsif ($arg[0] eq "" && %incomingDeal) {
		$messageSender->sendDealReply(3);
	} elsif ($arg[0] eq "" && $currentDeal{'you_finalize'} && $currentDeal{'other_finalize'}) {
		$messageSender->sendDealTrade();
		$currentDeal{'final'} = 1;
		message T("You accepted the final Deal\n"), "deal";
	} elsif ($arg[0] eq "" && %currentDeal) {
		$messageSender->sendDealAddItem(pack('v', 0), $currentDeal{'you_zeny'});
		$messageSender->sendDealFinalize();

	} elsif ($arg[0] eq "add" && !%currentDeal) {
		error T("Error in function 'deal_add' (Add Item to Deal)\n" .
			"No deal in progress\n");
	} elsif ($arg[0] eq "add" && $currentDeal{'you_finalize'}) {
		error T("Error in function 'deal_add' (Add Item to Deal)\n" .
			"Can't add any Items - You already finalized the deal\n");
	} elsif ($arg[0] eq "add" && $arg[1] =~ /\d+/ && !$char->inventory->get($arg[1])) {
		error TF("Error in function 'deal_add' (Add Item to Deal)\n" .
			"Inventory Item %s does not exist.\n", $arg[1]);
	} elsif ($arg[0] eq "add" && $arg[2] && $arg[2] !~ /\d+/) {
		error T("Error in function 'deal_add' (Add Item to Deal)\n" .
			"Amount must either be a number, or not specified.\n");
	} elsif ($arg[0] eq "add" && $arg[1] =~ /^(\d+(?:-\d+)?,?)+$/) {
		my $max_items = $config{dealMaxItems} || 10;
		my @items = Actor::Item::getMultiple($arg[1]);
		my $n = $currentDeal{you_items};
		if ($n >= $max_items) {
			error T("You can't add any more items to the deal\n"), "deal";
		}
		while (@items && $n < $max_items) {
			my $item = shift @items;
			next if $item->{equipped};
			dealAddItem( $item, min( $item->{amount}, $arg[2] || $item->{amount} ) );
			$n++;
		}
	} elsif ($arg[0] eq "add" && $arg[1] eq "z") {
		if (!$arg[2] && !($arg[2] eq "0") || $arg[2] > $char->{'zeny'}) {
			$arg[2] = $char->{'zeny'};
		}
		$currentDeal{'you_zeny'} = $arg[2];
		message TF("You put forward %sz to Deal\n", formatNumber($arg[2])), "deal";

	} elsif ($arg[0] eq "add" && $arg[1] !~ /^\d+$/) {
		my $max_items = $config{dealMaxItems} || 10;
		if ($currentDeal{you_items} > $max_items) {
			error T("You can't add any more items to the deal\n"), "deal";
		}
		my $items = [ grep { $_ && lc( $_->{name} ) eq lc( $arg[1] ) && !$_->{equipped} } @$char->inventory ];
		my $n = $currentDeal{you_items};
		my $a = $arg[2] || 1;
		my $c = 0;
		while ($n < $max_items && $c < $a && @$items) {
			my $item = shift @$items;
			my $amount = $arg[2] && $a - $c < $item->{amount} ? $a - $c : $item->{amount};
			dealAddItem($item, $amount);
			$n++;
			$c += $amount;
		}
	} else {
		error T("Syntax Error in function 'deal' (Deal a player)\n" .
			"Usage: deal [<Player # | no | add>] [<item #>] [<amount>]\n");
	}
}

sub cmdDealList {
	if (!%currentDeal) {
		error T("There is no deal list - You are not in a deal\n");

	} else {
		my $msg = center(T(" Current Deal "), 66, '-') ."\n";
		my $other_string = $currentDeal{'name'};
		my $you_string = T("You");
		if ($currentDeal{'other_finalize'}) {
			$other_string .= T(" - Finalized");
		}
		if ($currentDeal{'you_finalize'}) {
			$you_string .= T(" - Finalized");
		}

		$msg .= swrite(
			"@<<<<<<<<<<<<<<<<<<<<<<<<<<<<<   @<<<<<<<<<<<<<<<<<<<<<<<<<<<<<",
			[$you_string, $other_string]);

		my @currentDealYou;
		my @currentDealOther;
		foreach (keys %{$currentDeal{'you'}}) {
			push @currentDealYou, $_;
		}
		foreach (keys %{$currentDeal{'other'}}) {
			push @currentDealOther, $_;
		}

		my ($lastindex, $display, $display2);
		$lastindex = @currentDealOther;
		$lastindex = @currentDealYou if (@currentDealYou > $lastindex);
		for (my $i = 0; $i < $lastindex; $i++) {
			if ($i < @currentDealYou) {
				$display = ($items_lut{$currentDealYou[$i]} ne "")
					? $items_lut{$currentDealYou[$i]}
					: T("Unknown ").$currentDealYou[$i];
				$display .= " x $currentDeal{'you'}{$currentDealYou[$i]}{'amount'}";
			} else {
				$display = "";
			}
			if ($i < @currentDealOther) {
				$display2 = ($items_lut{$currentDealOther[$i]} ne "")
					? $items_lut{$currentDealOther[$i]}
					: T("Unknown ").$currentDealOther[$i];
				$display2 .= " x $currentDeal{'other'}{$currentDealOther[$i]}{'amount'}";
			} else {
				$display2 = "";
			}

			$msg .= swrite(
				"@<<<<<<<<<<<<<<<<<<<<<<<<<<<<<   @<<<<<<<<<<<<<<<<<<<<<<<<<<<<<",
				[$display, $display2]);
		}
		$you_string = ($currentDeal{'you_zeny'} ne "") ? $currentDeal{'you_zeny'} : 0;
		$other_string = ($currentDeal{'other_zeny'} ne "") ? $currentDeal{'other_zeny'} : 0;

		$msg .= swrite(
				T("zeny: \@<<<<<<<<<<<<<<<<<<<<<<<   zeny: \@<<<<<<<<<<<<<<<<<<<<<<<"),
				[formatNumber($you_string), formatNumber($other_string)]);

		$msg .= ('-'x66) . "\n";
		message $msg, "list";
	}
}

sub cmdDebug {
	my (undef, $args) = @_;
	my ($arg1) = $args =~ /^([\w\d]+)/;

	if ($arg1 eq "0") {
		configModify("debug", 0);
	} elsif ($arg1 eq "1") {
		configModify("debug", 1);
	} elsif ($arg1 eq "2") {
		configModify("debug", 2);

	} elsif ($arg1 eq "info") {
		my $connected = $net && "server=".($net->serverAlive ? "yes" : "no").
			",client=".($net->clientAlive ? "yes" : "no");
		my $time = $packetParser && sprintf("%.2f", time - $packetParser->{lastPacketTime});
		my $ai_timeout = sprintf("%.2f", time - $timeout{'ai'}{'time'});
		my $ai_time = sprintf("%.4f", time - $ai_v{'AI_last_finished'});

		message center(T(" Debug information "), 56, '-') ."\n".
			TF("ConState: %s\t\tConnected: %s\n" .
			"AI enabled: %s\n" .
			"\@ai_seq = %s\n" .
			"Last packet: %.2f secs ago\n" .
			"\$timeout{ai}: %.2f secs ago  (value should be >%s)\n" .
			"Last AI() call: %.2f secs ago\n" .
			('-'x56) . "\n",
		$conState, $connected, AI::state, "@ai_seq", $time, $ai_timeout,
		$timeout{'ai'}{'timeout'}, $ai_time), "list";
	}
}

sub cmdDoriDori {
	if (!$net || $net->getState() != Network::IN_GAME) {
		error TF("You must be logged in the game to use this command '%s'\n", shift);
		return;
	}
	my $headdir;
	if ($char->{look}{head} == 2) {
		$headdir = 1;
	} else {
		$headdir = 2;
	}
	$messageSender->sendLook($char->{look}{body}, $headdir);
}

sub cmdDrop {
	if (!$net || $net->getState() != Network::IN_GAME) {
		error TF("You must be logged in the game to use this command '%s'\n", shift);
		return;
	}
	my (undef, $args) = @_;
	my ($arg1) = $args =~ /^([\d,-]+)/;
	my ($arg2) = $args =~ /^[\d,-]+ (\d+)$/;
	if (($arg1 eq "") or ($arg1 < 0)) {
		error T("Syntax Error in function 'drop' (Drop Inventory Item)\n" .
			"Usage: drop <item #> [<amount>]\n");
	} else {
		my @temp = split(/,/, $arg1);
		@temp = grep(!/^$/, @temp); # Remove empty entries

		my @items = ();
		foreach (@temp) {
			if (/(\d+)-(\d+)/) {
				for ($1..$2) {
					push(@items, $_) if ($char->inventory->get($_));
				}
			} else {
				push @items, $_ if ($char->inventory->get($_));
			}
		}
		if (@items > 0) {
			main::ai_drop(\@items, $arg2);
		} else {
			error T("No items were dropped.\n");
		}
	}
}

sub cmdDump {
	dumpData((defined $incomingMessages) ? $incomingMessages->getBuffer() : '');
	quit();
}

sub cmdDumpNow {
	dumpData((defined $incomingMessages) ? $incomingMessages->getBuffer() : '');
}

sub cmdEmotion {
	# Show emotion
	if (!$net || $net->getState() != Network::IN_GAME) {
		error TF("You must be logged in the game to use this command '%s'\n", shift);
		return;
	}
	my (undef, $args) = @_;

	my $num = getEmotionByCommand($args);

	if (!defined $num) {
		error T("Syntax Error in function 'e' (Emotion)\n" .
			"Usage: e <command>\n");
	} else {
		$messageSender->sendEmotion($num);
	}
}

sub cmdEquip {

	# Equip an item
	my (undef, $args) = @_;
	my ($arg1,$arg2) = $args =~ /^(\S+)\s*(.*)/;
	my $slot;
	my $item;

	if ($arg1 eq "") {
		cmdEquip_list();
		return;
	}

	if ($arg1 eq "slots") {
		# Translation Comment: List of equiped items on each slot
		message T("Slots:\n") . join("\n", @Actor::Item::slots). "\n", "list";
		return;
	}

	if (!$net || $net->getState() != Network::IN_GAME) {
		error TF("You must be logged in the game to use this command '%s'\n", 'eq ' .$args);
		return;
	}

	if ($equipSlot_rlut{$arg1}) {
		$slot = $arg1;
	} else {
		$arg1 .= " $arg2" if $arg2;
	}

	$item = Actor::Item::get(defined $slot ? $arg2 : $arg1, undef, 1);
	if (!$item) {
		$args =~ s/^($slot)\s//g if ($slot);
		error TF("No such non-equipped Inventory Item: %s\n", $args);
		return;
	}

	if (!$item->{type_equip} && $item->{type} != 10 && $item->{type} != 16 && $item->{type} != 17 && $item->{type} != 8) {
		error TF("Inventory Item %s (%s) can't be equipped.\n",
			$item->{name}, $item->{binID});
		return;
	}
	if ($slot) {
		$item->equipInSlot($slot);
	} else {
		$item->equip();
	}
}

sub cmdEquip_list {
	if (!$char) {
		error T("Character equipment not yet ready\n");
		return;
	}
	for my $slot (@Actor::Item::slots) {
		my $item = $char->{equipment}{$slot};
		my $name = $item ? $item->{name} : '-';
		($item->{type} == 10 || $item->{type} == 16 || $item->{type} == 17 || $item->{type} == 19) ?
			message sprintf("%-15s: %s x %s\n", $slot, $name, $item->{amount}), "list" :
			message sprintf("%-15s: %s\n", $slot, $name), "list";
	}
}

sub cmdEval {
	if (!$Settings::lockdown) {
		if ($_[1] eq "") {
			error T("Syntax Error in function 'eval' (Evaluate a Perl expression)\n" .
				"Usage: eval <expression>\n");
		} else {
			package main;
			no strict;
			undef $@;
			eval $_[1];
			if (defined $@ && $@ ne '') {
				$@ .= "\n" if ($@ !~ /\n$/s);
				Log::error($@);
			}
		}
	}
}

sub cmdExp {
	my (undef, $args) = @_;
	my $knownArg;
	my $msg;

	# exp report
	my ($arg1) = $args =~ /^(\w+)/;

	if ($arg1 eq "reset") {
		$knownArg = 1;
		($bExpSwitch,$jExpSwitch,$totalBaseExp,$totalJobExp) = (2,2,0,0);
		$startTime_EXP = time;
		$startingzeny = $char->{zeny} if $char;
		undef @monsters_Killed;
		$dmgpsec = 0;
		$totaldmg = 0;
		$elasped = 0;
		$totalelasped = 0;
		undef %itemChange;
		$char->{'deathCount'} = 0;
		$bytesSent = 0;
		$packetParser->{bytesProcessed} = 0 if $packetParser;
		message T("Exp counter reset.\n"), "success";
		return;
	}

	if (!$char) {
		error T("Exp report not yet ready\n");
		return;
	}

	if ($arg1 eq "output") {
		open(F, ">>:utf8", "$Settings::logs_folder/exp.txt");
	}
	
	if (($arg1 eq "") || ($arg1 eq "report") || ($arg1 eq "output")) {
		$knownArg = 1;
		my ($endTime_EXP, $w_sec, $bExpPerHour, $jExpPerHour, $EstB_sec, $percentB, $percentJ, $zenyMade, $zenyPerHour, $EstJ_sec, $percentJhr, $percentBhr);
		$endTime_EXP = time;
		$w_sec = int($endTime_EXP - $startTime_EXP);
		if ($w_sec > 0) {
			$zenyMade = $char->{zeny} - $startingzeny;
			$bExpPerHour = int($totalBaseExp / $w_sec * 3600);
			$jExpPerHour = int($totalJobExp / $w_sec * 3600);
			$zenyPerHour = int($zenyMade / $w_sec * 3600);
			if ($char->{exp_max} && $bExpPerHour){
				$percentB = "(".sprintf("%.2f",$totalBaseExp * 100 / $char->{exp_max})."%)";
				$percentBhr = "(".sprintf("%.2f",$bExpPerHour * 100 / $char->{exp_max})."%)";
				$EstB_sec = int(($char->{exp_max} - $char->{exp})/($bExpPerHour/3600));
			}
			if ($char->{exp_job_max} && $jExpPerHour){
				$percentJ = "(".sprintf("%.2f",$totalJobExp * 100 / $char->{exp_job_max})."%)";
				$percentJhr = "(".sprintf("%.2f",$jExpPerHour * 100 / $char->{exp_job_max})."%)";
				$EstJ_sec = int(($char->{'exp_job_max'} - $char->{exp_job})/($jExpPerHour/3600));
			}
		}
		$char->{deathCount} = 0 if (!defined $char->{deathCount});

		$msg .= center(T(" Exp Report "), 50, '-') ."\n".
				TF( "Botting time : %s\n" .
					"BaseExp      : %s %s\n" .
					"JobExp       : %s %s\n" .
					"BaseExp/Hour : %s %s\n" .
					"JobExp/Hour  : %s %s\n" .
					"zeny         : %s\n" .
					"zeny/Hour    : %s\n" .
					"Base Levelup Time Estimation : %s\n" .
					"Job Levelup Time Estimation  : %s\n" .
					"Died : %s\n" .
					"Bytes Sent   : %s\n" .
					"Bytes Rcvd   : %s\n",
			timeConvert($w_sec), formatNumber($totalBaseExp), $percentB, formatNumber($totalJobExp), $percentJ,
			formatNumber($bExpPerHour), $percentBhr, formatNumber($jExpPerHour), $percentJhr,
			formatNumber($zenyMade), formatNumber($zenyPerHour), timeConvert($EstB_sec), timeConvert($EstJ_sec),
			$char->{'deathCount'}, formatNumber($bytesSent), $packetParser && formatNumber($packetParser->{bytesProcessed}));

		if ($arg1 eq "") {
			$msg .= ('-'x50) . "\n";
			message $msg, "list";
		}
	}

	if (($arg1 eq "monster") || ($arg1 eq "report") || ($arg1 eq "output")) {
		my $total;

		$knownArg = 1;

		$msg .= center(T(" Monster Killed Count "), 40, '-') ."\n".
			T("#   ID     Name                    Count\n");
		for (my $i = 0; $i < @monsters_Killed; $i++) {
			next if ($monsters_Killed[$i] eq "");
			$msg .= swrite(
				"@<< @<<<<< @<<<<<<<<<<<<<<<<<<<<<< @<<<<< ",
				[$i, $monsters_Killed[$i]{nameID}, $monsters_Killed[$i]{name}, $monsters_Killed[$i]{count}]);
			$total += $monsters_Killed[$i]{count};
		}
		$msg .= "\n" .
			TF("Total number of killed monsters: %s\n", $total) .
			('-'x40) . "\n";
		if ($arg1 eq "monster" || $arg1 eq "") {
			message $msg, "list";
		}
	}

	if (($arg1 eq "item") || ($arg1 eq "report") || ($arg1 eq "output")) {
		$knownArg = 1;

		$msg .= center(T(" Item Change Count "), 36, '-') ."\n".
			T("Name                           Count\n");
		for my $item (sort keys %itemChange) {
			next unless $itemChange{$item};
			$msg .= swrite(
				"@<<<<<<<<<<<<<<<<<<<<<<<<<<<<< @<<<<<<",
				[$item, $itemChange{$item}]);
		}
		$msg .= ('-'x36) . "\n";
		message $msg, "list";
		
		if ($arg1 eq "output") {
			print F $msg;
			close(F);
		}
	}

	if (!$knownArg) {
		error T("Syntax error in function 'exp' (Exp Report)\n" .
			"Usage: exp [<report | monster | item | reset>]\n");
	}
}

sub cmdFalcon {
	my (undef, $arg1) = @_;

	my $hasFalcon = $char && $char->statusActive('EFFECTSTATE_BIRD');
	if ($arg1 eq "") {
		if ($hasFalcon) {
			message T("Your falcon is active\n");
		} else {
			message T("Your falcon is inactive\n");
		}
	} elsif ($arg1 eq "release") {
		if (!$hasFalcon) {
			error T("Error in function 'falcon release' (Remove Falcon Status)\n" .
				"You don't possess a falcon.\n");
		} elsif (!$net || $net->getState() != Network::IN_GAME) {
			error TF("You must be logged in the game to use this command '%s'\n", 'falcon release');
			return;
		} else {
			$messageSender->sendCompanionRelease();
		}
	}
}

sub cmdFriend {
	my (undef, $args) = @_;
	my ($arg1, $arg2) = split(' ', $args, 2);

	if ($arg1 eq "") {
		my $msg = center(T(" Friends "), 36, '-') ."\n".
			T("#   Name                      Online\n");
		for (my $i = 0; $i < @friendsID; $i++) {
			$msg .= swrite(
				"@<  @<<<<<<<<<<<<<<<<<<<<<<<  @",
				[$i + 1, $friends{$i}{'name'}, $friends{$i}{'online'}? 'X':'']);
		}
		$msg .= ('-'x36) . "\n";
		message $msg, "list";

	} elsif (!$net || $net->getState() != Network::IN_GAME) {
		error TF("You must be logged in the game to use this command '%s'\n", 'friend ' .$arg1);
		return;

	} elsif ($arg1 eq "request") {
		my $player = Match::player($arg2);

		if (!$player) {
			error TF("Player %s does not exist\n", $arg2);
		} elsif (!defined $player->{name}) {
			error T("Player name has not been received, please try again\n");
		} else {
			my $alreadyFriend = 0;
			for (my $i = 0; $i < @friendsID; $i++) {
				if ($friends{$i}{'name'} eq $player->{name}) {
					$alreadyFriend = 1;
					last;
				}
			}
			if ($alreadyFriend) {
				error TF("%s is already your friend\n", $player->{name});
			} else {
				message TF("Requesting %s to be your friend\n", $player->{name});
				$messageSender->sendFriendRequest($players{$playersID[$arg2]}{name});
			}
		}

	} elsif ($arg1 eq "remove") {
		if ($arg2 < 1 || $arg2 > @friendsID) {
			error TF("Friend #%s does not exist\n", $arg2);
		} else {
			$arg2--;
			message TF("Attempting to remove %s from your friend list\n", $friends{$arg2}{'name'});
			$messageSender->sendFriendRemove($friends{$arg2}{'accountID'}, $friends{$arg2}{'charID'});
		}

	} elsif ($arg1 eq "accept") {
		if ($incomingFriend{'accountID'} eq "") {
			error T("Can't accept the friend request, no incoming request\n");
		} else {
			message TF("Accepting the friend request from %s\n", $incomingFriend{'name'});
			$messageSender->sendFriendListReply($incomingFriend{'accountID'}, $incomingFriend{'charID'}, 1);
			undef %incomingFriend;
		}

	} elsif ($arg1 eq "reject") {
		if ($incomingFriend{'accountID'} eq "") {
			error T("Can't reject the friend request - no incoming request\n");
		} else {
			message TF("Rejecting the friend request from %s\n", $incomingFriend{'name'});
			$messageSender->sendFriendListReply($incomingFriend{'accountID'}, $incomingFriend{'charID'}, 0);
			undef %incomingFriend;
		}

	} elsif ($arg1 eq "pm") {
		if ($arg2 < 1 || $arg2 > @friendsID) {
			error TF("Friend #%s does not exist\n", $arg2);
		} else {
			$arg2--;
			if (binFind(\@privMsgUsers, $friends{$arg2}{'name'}) eq "") {
				message TF("Friend %s has been added to the PM list as %s\n", $friends{$arg2}{'name'}, @privMsgUsers);
				$privMsgUsers[@privMsgUsers] = $friends{$arg2}{'name'};
			} else {
				message TF("Friend %s is already in the PM list\n", $friends{$arg2}{'name'});
			}
		}

	} else {
		error T("Syntax Error in function 'friend' (Manage Friends List)\n" .
			"Usage: friend [request|remove|accept|reject|pm]\n");
	}
}

sub cmdGetPlayerInfo {
	if (!$net || $net->getState() != Network::IN_GAME) {
		error TF("You must be logged in the game to use this command '%s'\n", shift);
		return;
	}
	my (undef, $args) = @_;
	return 0 if (isSafeActorQuery(pack("V", $args)) != 1); # Do not Query GM's
	$messageSender->sendGetPlayerInfo(pack("V", $args));
}

sub cmdGetCharacterName {
	if (!$net || $net->getState() != Network::IN_GAME) {
		error TF("You must be logged in the game to use this command '%s'\n", shift);
		return;
	}
	my (undef, $args) = @_;
	$messageSender->sendGetCharacterName(pack("V", $args));
}

sub helpIndent {
	my $cmd = shift;
	my $desc = shift;
	my @tmp = @{$desc};
	my $message;
	my $messageTmp;
	my @words;
	my $length = 0;

	$message = center(TF(" Help for '%s' ", $cmd), 79, "=")."\n";
	$message .= shift(@tmp) . "\n";

	foreach (@tmp) {
		$length = length($_->[0]) if length($_->[0]) > $length;
	}
	my $pattern = "$cmd %-${length}s    %s\n";
	my $padsize = length($cmd) + $length + 5;
	my $pad = sprintf("%-${padsize}s", '');

	foreach (@tmp) {
		if ($padsize + length($_->[1]) > 79) {
			@words = split(/ /, $_->[1]);
			$message .= sprintf("$cmd %-${length}s    ", $_->[0]);
			$messageTmp = '';
			foreach my $word (@words) {
				if ($padsize + length($messageTmp) + length($word) + 1 > 79) {
					$message .= $messageTmp . "\n$pad";
					$messageTmp = "$word ";
				} else {
					$messageTmp .= "$word ";
				}
			}
			$message .= $messageTmp."\n";
		}
		else {
			$message .= sprintf($pattern, $_->[0], $_->[1]);
		}
	}
	$message .= "=" x 79 . "\n";
	message $message, "list";
}

sub cmdIdentify {
	if (!$net || $net->getState() != Network::IN_GAME) {
		error TF("You must be logged in the game to use this command '%s'\n", shift);
		return;
	}
	my (undef, $arg1) = @_;
	if ($arg1 eq "" && @identifyID) {
		my $msg = center(T(" Identify List "), 50, '-') ."\n";
		for (my $i = 0; $i < @identifyID; $i++) {
			next if ($identifyID[$i] eq "");
			$msg .= swrite(
				"@<<< @<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<",
				[$i, $char->inventory->get($identifyID[$i])->{name}]);
		}
		$msg .= ('-'x50) . "\n";
		message $msg, "list";
	} elsif (!@identifyID) {
		error T("The identify list is empty, please use the identify skill or a magnifier first.\n");
	} elsif ($arg1 =~ /^\d+$/) {
		if ($identifyID[$arg1] eq "") {
			error TF("Error in function 'identify' (Identify Item)\n" .
				"Identify Item %s does not exist\n", $arg1);
		} else {
			$messageSender->sendIdentify($char->inventory->get($identifyID[$arg1])->{ID});
		}

	} else {
		error T("Syntax Error in function 'identify' (Identify Item)\n" .
			"Usage: identify [<identify #>]\n");
	}
}

sub cmdIgnore {
	if (!$net || $net->getState() != Network::IN_GAME) {
		error TF("You must be logged in the game to use this command '%s'\n", shift);
		return;
	}
	my (undef, $args) = @_;
	my ($arg1, $arg2) = $args =~ /^(\d+) ([\s\S]*)/;
	if ($arg1 eq "" || $arg2 eq "" || ($arg1 ne "0" && $arg1 ne "1")) {
		error T("Syntax Error in function 'ignore' (Ignore Player/Everyone)\n" .
			"Usage: ignore <flag> <name | all>\n");
	} else {
		if ($arg2 eq "all") {
			$messageSender->sendIgnoreAll(!$arg1);
		} else {
			$messageSender->sendIgnore($arg2, !$arg1);
		}
	}
}

sub cmdIhist {
	# Display item history
	my (undef, $args) = @_;
	$args = 5 if ($args eq "");

	if (!($args =~ /^\d+$/)) {
		error T("Syntax Error in function 'ihist' (Show Item History)\n" .
			"Usage: ihist [<number of entries #>]\n");

	} elsif (open(ITEM, "<", $Settings::item_log_file)) {
		my @item = <ITEM>;
		close(ITEM);
		my $msg = center(T(" Item History "), 79, '-') ."\n";
		my $i = @item - $args;
		$i = 0 if ($i < 0);
		for (; $i < @item; $i++) {
			$msg .= $item[$i];
		}
		$msg .= ('-'x50) . "\n";
		message $msg, "list";

	} else {
		error TF("Unable to open %s\n", $Settings::item_log_file);
	}
}


=pod
=head2 cmdInventory

Console command that displays a character's inventory contents
- With pretty text headers
- Items are displayed from lowest index to highest index, but, grouped
  in the following sub-categories:
  eq - Equipped Items (such as armour, shield, weapon in L/R/both hands)
  neq- Non-equipped equipment items
  nu - Non-usable items
  u - Usable (consumable) items

All items that are not identified will be suffixed with
"-- Not Identified" on the end.

Syntax: i [eq|neq|nu|u|desc <IndexNumber>]

Invalid arguments to this command will display an error message to 
inform and correct the user.

All text strings for headers, and to indicate Non-identified or pending
sale items should be translatable.

=cut
sub cmdInventory {
	# Display inventory items
	my (undef, $args) = @_;
	my ($arg1) = $args =~ /^(\w+)/;
	my ($arg2) = $args =~ /^\w+ (.+)/;
	
	if (!$char || !$char->inventory->isReady()) {
		error "Inventory is not available\n";
		return;
	}
	
	if ($char->inventory->size() == 0) {
		error T("Inventory is empty\n");
		return;
	}

	if ($arg1 eq "" || $arg1 eq "eq" || $arg1 eq "neq" || $arg1 eq "u" || $arg1 eq "nu") {
		my @useable;
		my @equipment;
		my @uequipment;
		my @non_useable;
		my ($i, $display, $index, $sell);

		for my $item (@{$char->inventory}) {
			if ($item->usable) {
				push @useable, $item->{binID};
			} elsif ($item->equippable && $item->{type_equip} != 0) {
				my %eqp;
				$eqp{index} = $item->{ID};
				$eqp{binID} = $item->{binID};
				$eqp{name} = $item->{name};
				$eqp{amount} = $item->{amount};
				$eqp{equipped} = ($item->{type} == 10 || $item->{type} == 16 || $item->{type} == 17 || $item->{type} == 19) ? $item->{amount} . " left" : $equipTypes_lut{$item->{equipped}};
				$eqp{type} = $itemTypes_lut{$item->{type}};
				$eqp{equipped} .= " ($item->{equipped})";
				# Translation Comment: Mark to tell item not identified
				$eqp{identified} = " -- " . T("Not Identified") if !$item->{identified};
				if ($item->{equipped}) {
					push @equipment, \%eqp;
				} else {
					push @uequipment, \%eqp;
				}
			} else {
				push @non_useable, $item->{binID};
			}
		}
		# Start header -- Note: Title is translatable.
		my $msg = center(T(" Inventory "), 50, '-') ."\n";

		if ($arg1 eq "" || $arg1 eq "eq") {
			# Translation Comment: List of equipment items worn by character
			$msg .= T("-- Equipment (Equipped) --\n");
			foreach my $item (@equipment) {
				$sell = defined(findIndex(\@sellList, "binID", $item->{binID})) ? T("Will be sold") : "";
				$display = sprintf("%-3d  %s -- %s", $item->{binID}, $item->{name}, $item->{equipped});
				$msg .= sprintf("%-57s %s\n", $display, $sell);
			}
		}

		if ($arg1 eq "" || $arg1 eq "neq") {
			# Translation Comment: List of equipment items NOT worn
			$msg .= T("-- Equipment (Not Equipped) --\n");
			foreach my $item (@uequipment) {
				$sell = defined(findIndex(\@sellList, "binID", $item->{binID})) ? T("Will be sold") : "";
				$display = sprintf("%-3d  %s (%s)", $item->{binID}, $item->{name}, $item->{type});
				$display .= " x $item->{amount}" if $item->{amount} > 1;
				$display .= $item->{identified};
				$msg .= sprintf("%-57s %s\n", $display, $sell);
			}
		}

		if ($arg1 eq "" || $arg1 eq "nu") {
			# Translation Comment: List of non-usable items
			$msg .= T("-- Non-Usable --\n");
			for ($i = 0; $i < @non_useable; $i++) {
				$index = $non_useable[$i];
				my $item = $char->inventory->get($index);
				$display = $item->{name};
				$display .= " x $item->{amount}";
				# Translation Comment: Tell if the item is marked to be sold
				$sell = defined(findIndex(\@sellList, "binID", $index)) ? T("Will be sold") : "";
				$msg .= swrite(
					"@<<< @<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< @<<<<<<<<<<<<",
					[$index, $display, $sell]);
			}
		}

		if ($arg1 eq "" || $arg1 eq "u") {
			# Translation Comment: List of usable items
			$msg .= T("-- Usable --\n");
			for ($i = 0; $i < @useable; $i++) {
				$index = $useable[$i];
				my $item = $char->inventory->get($index);
				$display = $item->{name};
				$display .= " x $item->{amount}";
				$sell = defined(findIndex(\@sellList, "binID", $index)) ? T("Will be sold") : "";
				$msg .= swrite(
					"@<<< @<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< @<<<<<<<<<<<<",
					[$index, $display, $sell]);
			}
		}

		$msg .= ('-'x50) . "\n"; #Add footer onto end of list.
		message $msg, "list";

	} elsif ($arg1 eq "desc" && $arg2 ne "") {
		cmdInventory_desc($arg2);

	} else {
		error T("Syntax Error in function 'i' (Inventory List)\n" .
			"Usage: i [<u|eq|neq|nu|desc>] [<inventory item>]\n");
	}
}

sub cmdInventory_desc {
	my ($name) = @_;

	my $item = Match::inventoryItem($name);
	if (!$item) {
		error TF("Error in function 'i' (Inventory Item Description)\n" .
			"Inventory Item %s does not exist\n", $name);
		return;
	}

	printItemDesc($item->{nameID});
}

sub cmdItemList {
	my $msg = center(T(" Item List "), 46, '-') ."\n".
		T("   # Name                           Coord\n");
	for (my $i = 0; $i < @itemsID; $i++) {
		next if ($itemsID[$i] eq "");
		my $item = $items{$itemsID[$i]};
		my $display = "$item->{name} x $item->{amount}";
		$msg .= sprintf("%4d %-30s (%3d, %3d)\n",
			$i, $display, $item->{pos}{x}, $item->{pos}{y});
	}
	$msg .= ('-'x46) . "\n";
	message $msg, "list";
}

sub cmdItemLogClear {
	itemLog_clear();
	message T("Item log cleared.\n"), "success";
}

#sub cmdJudge {
#	my (undef, $args) = @_;
#	my ($arg1) = $args =~ /^(\d+)/;
#	my ($arg2) = $args =~ /^\d+ (\d+)/;
#	if ($arg1 eq "" || $arg2 eq "") {
#		error	"Syntax Error in function 'judge' (Give an alignment point to Player)\n" .
#			"Usage: judge <player #> <0 (good) | 1 (bad)>\n";
#	} elsif ($playersID[$arg1] eq "") {
#		error	"Error in function 'judge' (Give an alignment point to Player)\n" .
#			"Player $arg1 does not exist.\n";
#	} else {
#		$arg2 = ($arg2 >= 1);
#		$messageSender->sendAlignment($playersID[$arg1], $arg2);
#	}
#}

sub cmdKill {
	my (undef, $ID) = @_;

	my $target = $playersID[$ID];
	unless ($target) {
		error TF("Player %s does not exist.\n", $ID);
		return;
	}

	attack($target);
}

sub cmdLook {
	my (undef, $args) = @_;
	my ($arg1) = $args =~ /^(\d+)/;
	my ($arg2) = $args =~ /^\d+ (\d+)$/;
	if ($arg1 eq "") {
		error T("Syntax Error in function 'look' (Look a Direction)\n" .
			"Usage: look <body dir> [<head dir>]\n");
	} else {
		look($arg1, $arg2);
	}
}

sub cmdLookPlayer {
	my (undef, $arg1) = @_;
	if ($arg1 eq "") {
		error T("Syntax Error in function 'lookp' (Look at Player)\n" .
			"Usage: lookp <player #>\n");
	} elsif (!$playersID[$arg1]) {
		error TF("Error in function 'lookp' (Look at Player)\n" .
			"'%s' is not a valid player number.\n", $arg1);
	} else {
		lookAtPosition($players{$playersID[$arg1]}{pos_to});
	}
}

sub cmdManualMove {
	if (!$net || $net->getState() != Network::IN_GAME) {
		error TF("You must be logged in the game to use this command '%s'\n", shift);
		return;
	}
	my ($switch, $steps) = @_;
	if (!$steps) {
		$steps = 5;
	} elsif ($steps !~ /^\d+$/) {
		error TF("Error in function '%s' (Manual Move)\n" .
			"Usage: %s [distance]\n", $switch, $switch);
		return;
	}
	if ($switch eq "east") {
		manualMove($steps, 0);
	} elsif ($switch eq "west") {
		manualMove(-$steps, 0);
	} elsif ($switch eq "north") {
		manualMove(0, $steps);
	} elsif ($switch eq "south") {
		manualMove(0, -$steps);
	} elsif ($switch eq "northeast") {
		manualMove($steps, $steps);
	} elsif ($switch eq "southwest") {
		manualMove(-$steps, -$steps);
	} elsif ($switch eq "northwest") {
		manualMove(-$steps, $steps);
	} elsif ($switch eq "southeast") {
		manualMove($steps, -$steps);
	}
}

sub cmdMemo {
	if (!$net || $net->getState() != Network::IN_GAME) {
		error TF("You must be logged in the game to use this command '%s'\n", shift);
		return;
	}
	$messageSender->sendMemo();
}

sub cmdMonsterList {
	my (undef, $args) = @_;
	if ($args =~ /^\d+$/) {
		if (my $monster = $monstersList->get($args)) {
			my $msg = center(T(" Monster Info "), 50, '-') ."\n".
				TF("%s (%d)\n" .
				"Walk speed: %s secs per block\n",
			$monster->name, $monster->{binID},
			$monster->{walk_speed});
			$msg .= TF("Statuses: %s \n", $monster->statusesString);
			$msg .= '-' x 50 . "\n";
			message $msg, "info";
		} else {
			error TF("Monster \"%s\" does not exist.\n", $args);
		}
	} else {
		my ($dmgTo, $dmgFrom, $dist, $pos, $name, $monsters);
		my $msg = center(T(" Monster List "), 79, '-') ."\n".
			T("#   Name                        ID      DmgTo DmgFrom  Distance    Coordinates\n");
		for my $monster (@$monstersList) {
			$dmgTo = ($monster->{dmgTo} ne "")
				? $monster->{dmgTo}
				: 0;
			$dmgFrom = ($monster->{dmgFrom} ne "")
				? $monster->{dmgFrom}
				: 0;
			$dist = distance($char->{pos_to}, $monster->{pos_to});
			$dist = sprintf("%.1f", $dist) if (index($dist, '.') > -1);
			$pos = '(' . $monster->{pos_to}{x} . ', ' . $monster->{pos_to}{y} . ')';
			$name = $monster->name;
			if ($name ne $monster->{name_given}) {
				$name .= '[' . $monster->{name_given} . ']';
			}
			$msg .= swrite(
				"@<< @<<<<<<<<<<<<<<<<<<<<<<<<<< @<<<<<< @<<<< @<<<<    @<<<<<      @<<<<<<<<<<",
				[$monster->{binID}, $name, $monster->{binType}, $dmgTo, $dmgFrom, $dist, $pos]);
		}
		$msg .= ('-'x79) . "\n";
		message $msg, "list";
	}
}

sub cmdMove {
	if (!$net || $net->getState() != Network::IN_GAME) {
		error TF("You must be logged in the game to use this command '%s'\n", shift);
		return;
	}
	my (undef, $args) = @_;
	my @args_split = split(/\s+/, $args);

	my ($map_or_portal, $x, $y, $dist);
	if (($args_split[0] =~ /^\d+$/) && ($args_split[1] =~ /^\d+$/) && ($args_split[2] =~ /^\S+$/)) {
		# coordinates and map
		$map_or_portal = $args_split[2];
		$x = $args_split[0];
		$y = $args_split[1];
	} elsif (($args_split[0] =~ /^\S+$/) && ($args_split[1] =~ /^\d+$/) && ($args_split[2] =~ /^\d+$/)) {
		# map and coordinates
		$map_or_portal = $args_split[0];
		$x = $args_split[1];
		$y = $args_split[2];
	} elsif (($args_split[0] =~ /^\S+$/) && !$args_split[1]) {
		# map only
		$map_or_portal = $args_split[0];
	} elsif (($args_split[0] =~ /^\d+$/) && ($args_split[1] =~ /^\d+$/) && !$args_split[2]) {
		# coordinates only
		$map_or_portal = $field->baseName;
		$x = $args_split[0];
		$y = $args_split[1];
	} else {
		error T("Syntax Error in function 'move' (Move Player)\n" .
			"Usage: move <x> <y> [<map> [<distance from coordinates>]]\n" .
			"       move <map> [<x> <y> [<distance from coordinates>]]\n" .
			"       move <portal#>\n");
	}

	# if (($args_split[0] =~ /^\d+$/) && ($args_split[1] =~ /^\d+$/) && ($args_split[2] =~ /^\d+$/)) {
		# # distance from x, y
		# $dist = $args_split[2];
	# } elsif {
	if ($args_split[3] =~ /^\d+$/) {
		# distance from map x, y
		$dist = $args_split[3];
	}


	if ($map_or_portal eq "stop") {
		AI::clear(qw/move route mapRoute/);
		message T("Stopped all movement\n"), "success";
	} else {
		AI::clear(qw/move route mapRoute/);
		if ($currentChatRoom ne "") {
			error T("Error in function 'move' (Move Player)\n" .
				"Unable to walk while inside a chat room!\n" .
				"Use the command: chat leave\n");
		} elsif ($shopstarted) {
			error T("Error in function 'move' (Move Player)\n" .
				"Unable to walk while the shop is open!\n" .
				"Use the command: closeshop\n");
		} else {
			if ($map_or_portal =~ /^\d+$/) {
				if ($portalsID[$map_or_portal]) {
					message TF("Move into portal number %s (%s,%s)\n",
						$map_or_portal, $portals{$portalsID[$map_or_portal]}{'pos'}{'x'}, $portals{$portalsID[$map_or_portal]}{'pos'}{'y'});
					main::ai_route($field->baseName, $portals{$portalsID[$map_or_portal]}{'pos'}{'x'}, $portals{$portalsID[$map_or_portal]}{'pos'}{'y'}, attackOnRoute => 1, noSitAuto => 1);
				} else {
					error T("No portals exist.\n");
				}
			} else {
				# map
				$map_or_portal =~ s/^(\w{3})?(\d@.*)/$2/; # remove instance. is it possible to move to an instance? if not, we could throw an error here
				# TODO: implement Field::sourceName function here once they are implemented there - 2013.11.26
				my $file = $map_or_portal.'.fld';
				$file = File::Spec->catfile($Settings::fields_folder, $file) if ($Settings::fields_folder);
				$file .= ".gz" if (! -f $file); # compressed file
				if ($maps_lut{"${map_or_portal}.rsw"}) {
					if ($dist) {
						message TF("Calculating route to: %s(%s): %s, %s (Distance: %s)\n",
							$maps_lut{$map_or_portal.'.rsw'}, $map_or_portal, $x, $y, $dist), "route";
					} elsif ($x ne "") {
						message TF("Calculating route to: %s(%s): %s, %s\n",
							$maps_lut{$map_or_portal.'.rsw'}, $map_or_portal, $x, $y), "route";
					} else {
						message TF("Calculating route to: %s(%s)\n",
							$maps_lut{$map_or_portal.'.rsw'}, $map_or_portal), "route";
					}
					main::ai_route($map_or_portal, $x, $y,
						attackOnRoute => 1,
						noSitAuto => 1,
						notifyUponArrival => 1,
						distFromGoal => $dist);
				} elsif (-f $file) {
					# valid map
					my $map_name = $maps_lut{"${map_or_portal}.rsw"}?$maps_lut{"${map_or_portal}.rsw"}:
						T('Unknown Map');
					if ($dist) {
						message TF("Calculating route to: %s(%s): %s, %s (Distance: %s)\n",
							$map_name, $map_or_portal, $x, $y, $dist), "route";
					} elsif ($x ne "") {
						message TF("Calculating route to: %s(%s): %s, %s\n",
							$map_name, $map_or_portal, $x, $y), "route";
					} else {
						message TF("Calculating route to: %s(%s)\n",
							$map_name, $map_or_portal), "route";
					}
					main::ai_route($map_or_portal, $x, $y,
					attackOnRoute => 1,
					noSitAuto => 1,
					notifyUponArrival => 1,
					distFromGoal => $dist);
				} else {
					error TF("Map %s does not exist\n", $map_or_portal);
				}
			}
		}
	}
}

sub cmdNPCList {
	my (undef, $args) = @_;
	my @arg = parseArgs($args);
	my $msg = center(T(" NPC List "), 57, '-') ."\n".
		T("#    Name                         Coordinates   ID\n");
	if ($npcsList) {
		if ($arg[0] =~ /^\d+$/) {
			my $i = $arg[0];
			if (my $npc = $npcsList->get($i)) {
				my $pos = "($npc->{pos_to}{x}, $npc->{pos_to}{y})";
				$msg .= swrite(
					"@<<< @<<<<<<<<<<<<<<<<<<<<<<<<<<< @<<<<<<<<<<   @<<<<<<<<",
					[$i, $npc->name, $pos, $npc->{nameID}]);
				$msg .= ('-'x57) . "\n";
				message $msg, "list";

			} else {
				error T("Syntax Error in function 'nl' (List NPCs)\n" .
					"Usage: nl [<npc #>]\n");
			}
			return;
		}

		for my $npc (@$npcsList) {
			my $pos = "($npc->{pos}{x}, $npc->{pos}{y})";
			$msg .= swrite(
				"@<<< @<<<<<<<<<<<<<<<<<<<<<<<<<<< @<<<<<<<<<<   @<<<<<<<<",
				[$npc->{binID}, $npc->name, $pos, $npc->{nameID}]);
		}
	}
	$msg .= ('-'x57) . "\n";
	message $msg, "list";
}

sub cmdOpenShop {
	if (!$net || $net->getState() != Network::IN_GAME) {
		error TF("You must be logged in the game to use this command '%s'\n", shift);
		return;
	}

	if ($config{'shop_useSkill'}) {
		# This method is responsible to NOT uses a bug in which openkore opens the shop,
		# using a vending skill and then open the shop
		my $skill = new Skill(auto => "MC_VENDING");

		require Task::UseSkill;
		my $skillTask = new Task::UseSkill(
			actor => $skill->getOwner,
			skill => $skill,
			priority => Task::USER_PRIORITY
		);
		my $task = new Task::Chained(
			name => 'openShop',
			tasks => [
				new Task::ErrorReport(task => $skillTask),
				Task::Timeout->new(
					function => sub {main::openShop()},
					seconds => $timeout{ai_shop_useskill_delay}{timeout} ? $timeout{ai_shop_useskill_delay}{timeout} : 5,
				)
			]
		);
		$taskManager->add($task);
	} else {
		# This method is responsible to uses a bug in which openkore opens the shop
		# without using a vending skill

		main::openShop();
	}
}

sub cmdPlayerList {
	my (undef, $args) = @_;
	my $msg;

	if ($args eq "g") {
		my $maxplg;
		$msg = center(T(" Guild Player List "), 79, '-') ."\n".
			T("#    Name                                Sex   Lv   Job         Dist Coord\n");
		for my $player (@$playersList) {
			my ($name, $dist, $pos);
			$name = $player->name;

			if ($char->{guild}{name} eq ($player->{guild}{name})) {

				if ($player->{guild} && %{$player->{guild}}) {
					$name .= " [$player->{guild}{name}]";
				}
				$dist = distance($char->{pos_to}, $player->{pos_to});
				$dist = sprintf("%.1f", $dist) if (index ($dist, '.') > -1);
				$pos = '(' . $player->{pos_to}{x} . ', ' . $player->{pos_to}{y} . ')';

				$maxplg++;

				$msg .= swrite(
					"@<<< @<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< @<<<< @<<< @<<<<<<<<<< @<<< @<<<<<<<<<",
					[$player->{binID}, $name, $sex_lut{$player->{sex}}, $player->{lv}, $player->job, $dist, $pos]);
			}
		}
		$msg .= TF("Total guild players: %s\n",$maxplg) if $maxplg;
		if (my $totalPlayers = $playersList && $playersList->size) {
			$msg .= TF("Total players: %s \n", $totalPlayers);
		} else {
			$msg .= T("There are no players near you.\n");
		}
		$msg .= ('-'x79) . "\n";
		message $msg, "list";
		return;
	}

	if ($args eq "p") {
		my $maxplp;
		$msg = center(T(" Party Player List "), 79, '-') ."\n".
			T("#    Name                                Sex   Lv   Job         Dist Coord\n");
		for my $player (@$playersList) {
			my ($name, $dist, $pos);
			$name = $player->name;

			if ($char->{party}{name} eq ($player->{party}{name})) {

				if ($player->{guild} && %{$player->{guild}}) {
					$name .= " [$player->{guild}{name}]";
				}
				$dist = distance($char->{pos_to}, $player->{pos_to});
				$dist = sprintf("%.1f", $dist) if (index ($dist, '.') > -1);
				$pos = '(' . $player->{pos_to}{x} . ', ' . $player->{pos_to}{y} . ')';

				$maxplp++;

				$msg .= swrite(
					"@<<< @<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< @<<<< @<<< @<<<<<<<<<< @<<< @<<<<<<<<<",
					[$player->{binID}, $name, $sex_lut{$player->{sex}}, $player->{lv}, $player->job, $dist, $pos]);
			}
		}
		$msg .= TF("Total party players: %s \n",$maxplp)  if $maxplp;
		if (my $totalPlayers = $playersList && $playersList->size) {
			$msg .= TF("Total players: %s \n", $totalPlayers);
		} else {
			$msg .= T("There are no players near you.\n");
		}
		$msg .= ('-'x79) . "\n";
		message $msg, "list";
		return;
	}

	if ($args ne "") {
		my Actor::Player $player = Match::player($args) if ($playersList);
		if (!$player) {
			error TF("Player \"%s\" does not exist.\n", $args);
			return;
		}

		my $ID = $player->{ID};
		my $body = $player->{look}{body} % 8;
		my $head = $player->{look}{head};
		if ($head == 0) {
			$head = $body;
		} elsif ($head == 1) {
			$head = $body - 1;
		} else {
			$head = $body + 1;
		}

		my $pos = calcPosition($player);
		my $mypos = calcPosition($char);
		my $dist = sprintf("%.1f", distance($pos, $mypos));
		$dist =~ s/\.0$//;

		my %vecPlayerToYou;
		my %vecYouToPlayer;
		getVector(\%vecPlayerToYou, $mypos, $pos);
		getVector(\%vecYouToPlayer, $pos, $mypos);
		my $degPlayerToYou = vectorToDegree(\%vecPlayerToYou);
		my $degYouToPlayer = vectorToDegree(\%vecYouToPlayer);
		my $hex = getHex($ID);
		my $playerToYou = int(sprintf("%.0f", (360 - $degPlayerToYou) / 45)) % 8;
		my $youToPlayer = int(sprintf("%.0f", (360 - $degYouToPlayer) / 45)) % 8;
		my $headTop = headgearName($player->{headgear}{top});
		my $headMid = headgearName($player->{headgear}{mid});
		my $headLow = headgearName($player->{headgear}{low});

		$msg = center(T(" Player Info "), 67, '-') ."\n" .
			$player->name . " (" . $player->{binID} . ")\n" .
		TF("Account ID: %s (Hex: %s)\n" .
			"Party: %s\n" .
			"Guild: %s\n" .
			"Guild title: %s\n" .
			"Position: %s, %s (%s of you: %s degrees)\n" .
			"Level: %-7d Distance: %-17s\n" .
			"Sex: %-6s    Class: %s\n\n" .
			"Body direction: %-19s Head direction:  %-19s\n" .
			"Weapon: %s\n" .
			"Shield: %s\n" .
			"Upper headgear: %-19s Middle headgear: %-19s\n" .
			"Lower headgear: %-19s Hair color:      %-19s\n" .
			"Walk speed: %s secs per block\n",
		$player->{nameID}, $hex,
		($player->{party} && $player->{party}{name} ne '') ? $player->{party}{name} : '',
		($player->{guild}) ? $player->{guild}{name} : '',
		($player->{guild}) ? $player->{guild}{title} : '',
		$pos->{x}, $pos->{y}, $directions_lut{$youToPlayer}, int($degYouToPlayer),
		$player->{lv}, $dist, $sex_lut{$player->{sex}}, $jobs_lut{$player->{jobID}},
		"$directions_lut{$body} ($body)", "$directions_lut{$head} ($head)",
		itemName({nameID => $player->{weapon}}),
		itemName({nameID => $player->{shield}}),
		$headTop, $headMid,
			  $headLow, "$haircolors{$player->{hair_color}} ($player->{hair_color})",
			  $player->{walk_speed});
		if ($player->{dead}) {
			$msg .= T("Player is dead.\n");
		} elsif ($player->{sitting}) {
			$msg .= T("Player is sitting.\n");
		}

		if ($degPlayerToYou >= $head * 45 - 29 && $degPlayerToYou <= $head * 45 + 29) {
			$msg .= T("Player is facing towards you.\n");
		}
		$msg .= TF("\nStatuses: %s \n", $player->statusesString);
		$msg .= '-' x 67 . "\n";
		message $msg, "info";
		return;
	}

	{
		$msg = center(T(" Player List "), 79, '-') ."\n".
		T("#    Name                                Sex   Lv   Job         Dist Coord\n");
		for my $player (@$playersList) {
			my ($name, $dist, $pos);
			$name = $player->name;
			if ($player->{guild} && %{$player->{guild}}) {
				$name .= " [$player->{guild}{name}]";
			}
			$dist = distance($char->{pos_to}, $player->{pos_to});
			$dist = sprintf("%.1f", $dist) if (index ($dist, '.') > -1);
			$pos = '(' . $player->{pos_to}{x} . ', ' . $player->{pos_to}{y} . ')';
			$msg .= swrite(
				"@<<< @<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< @<<<< @<<< @<<<<<<<<<< @<<< @<<<<<<<<<",
				[$player->{binID}, $name, $sex_lut{$player->{sex}}, $player->{lv}, $player->job, $dist, $pos]);
		}
		if (my $playersTotal = $playersList && $playersList->size) {
			$msg .= TF("Total players: %s \n", $playersTotal);
		} else	{$msg .= T("There are no players near you.\n");}
		$msg .= '-' x 79 . "\n";
		message $msg, "list";
	}
}

sub cmdPlugin {
	return if ($Settings::lockdown);
	my (undef, $input) = @_;
	my @args = split(/ +/, $input, 2);

	if (@args == 0) {
		my $msg = center(T(" Currently loaded plugins "), 79, '-') ."\n".
				T("#   Name                 Description\n");
		my $i = -1;
		foreach my $plugin (@Plugins::plugins) {
			$i++;
			next unless $plugin;
			$msg .= swrite(
				"@<< @<<<<<<<<<<<<<<<<<<< @<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<",
				[$i, $plugin->{name}, $plugin->{description}]);
		}
		$msg .= ('-'x79) . "\n";
		message $msg, "list";

	} elsif ($args[0] eq 'reload') {
		my @names;

		if ($args[1] =~ /^\d+$/) {
			push @names, $Plugins::plugins[$args[1]]{name};

		} elsif ($args[1] eq '') {
			error T("Syntax Error in function 'plugin reload' (Reload Plugin)\n" .
				"Usage: plugin reload <plugin name|plugin number#|\"all\">\n");
			return;

		} elsif ($args[1] eq 'all') {
			foreach my $plugin (@Plugins::plugins) {
				next unless $plugin;
				push @names, $plugin->{name};
			}

		} else {
			foreach my $plugin (@Plugins::plugins) {
				next unless $plugin;
				if ($plugin->{name} =~ /$args[1]/i) {
					push @names, $plugin->{name};
				}
			}
			if (!@names) {
				error T("Error in function 'plugin reload' (Reload Plugin)\n" .
					"The specified plugin names do not exist.\n");
				return;
			}
		}

		foreach (my $i = 0; $i < @names; $i++) {
			Plugins::reload($names[$i]);
		}

	} elsif ($args[0] eq 'load') {
		if ($args[1] eq '') {
			error T("Syntax Error in function 'plugin load' (Load Plugin)\n" .
				"Usage: plugin load <filename|\"all\">\n");
			return;
		} elsif ($args[1] eq 'all') {
			Plugins::loadAll();
		} else {
			if (-e $args[1]) {
			# then search inside plugins folder !
				Plugins::load($args[1]);
			} elsif (-e $Plugins::current_plugin_folder."\\".$args[1]) {
				Plugins::load($Plugins::current_plugin_folder."\\".$args[1]);
			} elsif (-e $Plugins::current_plugin_folder."\\".$args[1].".pl") {
				# we'll try to add .pl ....
				Plugins::load($Plugins::current_plugin_folder."\\".$args[1].".pl");
			}
		}

	} elsif ($args[0] eq 'unload') {
		if ($args[1] =~ /^\d+$/) {
			if ($Plugins::plugins[$args[1]]) {
				my $name = $Plugins::plugins[$args[1]]{name};
				Plugins::unload($name);
				message TF("Plugin %s unloaded.\n", $name), "system";
			} else {
				error TF("'%s' is not a valid plugin number.\n", $args[1]);
			}

		} elsif ($args[1] eq '') {
			error T("Syntax Error in function 'plugin unload' (Unload Plugin)\n" .
				"Usage: plugin unload <plugin name|plugin number#|\"all\">\n");
			return;

		} elsif ($args[1] eq 'all') {
			Plugins::unloadAll();

		} else {
			foreach my $plugin (@Plugins::plugins) {
				next unless $plugin;
				if ($plugin->{name} =~ /$args[1]/i) {
					my $name = $plugin->{name};
					Plugins::unload($name);
					message TF("Plugin %s unloaded.\n", $name), "system";
				}
			}
		}

	} else {
		my $msg = center(T(" Plugin command syntax "), 79, '-') ."\n" .
			T("Command:                                              Description:\n" .
			" plugin                                                List loaded plugins\n" .
			" plugin load <filename>                                Load a plugin\n" .
			" plugin unload <plugin name|plugin number#|\"all\">      Unload a loaded plugin\n" .
			" plugin reload <plugin name|plugin number#|\"all\">      Reload a loaded plugin\n") .
			('-'x79) . "\n";
		if ($args[0] eq 'help') {
			message $msg, "info";
		} else {
			error T("Syntax Error in function 'plugin' (Control Plugins)\n");
			error $msg;
		}
	}
}

sub cmdPMList {
	my $msg = center(T(" PM List "), 30, '-') ."\n";
	for (my $i = 1; $i <= @privMsgUsers; $i++) {
		$msg .= swrite(
			"@<<< @<<<<<<<<<<<<<<<<<<<<<<<",
			[$i, $privMsgUsers[$i - 1]]);
	}
	$msg .= ('-'x30) . "\n";
	message $msg, "list";
}

sub cmdPortalList {
	my (undef, $args) = @_;
	my ($arg) = parseArgs($args,1);
	if ($arg eq '') {
		my $msg = center(T(" Portal List "), 52, '-') ."\n".
			T("#    Name                                Coordinates\n");
		for (my $i = 0; $i < @portalsID; $i++) {
			next if $portalsID[$i] eq "";
			my $portal = $portals{$portalsID[$i]};
			my $coords = "($portal->{pos}{x}, $portal->{pos}{y})";
			$msg .= swrite(
				"@<<< @<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< @<<<<<<<<<",
				[$i, $portal->{name}, $coords]);
		}
		$msg .= ('-'x52) . "\n";
		message $msg, "list";
	} elsif ($arg eq 'recompile') {
		Settings::loadByRegexp(qr/portals/);
		Misc::compilePortals() if Misc::compilePortals_check();
	} elsif ($arg =~ /^add (.*)$/) { #Manual adding portals
		#Command: portals add mora 56 25 bif_fild02 176 162
		#Command: portals add y_airport 143 43 y_airport 148 51 0 c r0 c r0
		debug "Input: $args\n";
		my ($srcMap, $srcX, $srcY, $dstMap, $dstX, $dstY, $seq) = $args =~ /^add ([a-zA-Z\_\-0-9]*) (\d{1,3}) (\d{1,3}) ([a-zA-Z\_\-0-9]*) (\d{1,3}) (\d{1,3})(.*)$/; #CHECKING
		my $srcfile = $srcMap.'.fld';
		$srcfile = File::Spec->catfile($Settings::fields_folder, $srcfile) if ($Settings::fields_folder);
		$srcfile .= ".gz" if (! -f $srcfile); # compressed file
		my $dstfile = $dstMap.'.fld';
		$dstfile = File::Spec->catfile($Settings::fields_folder, $dstfile) if ($Settings::fields_folder);
		$dstfile .= ".gz" if (! -f $dstfile); # compressed file
		error TF("Files '%s' or '%s' does not exist.\n", $srcfile, $dstfile) if (! -f $srcfile || ! -f $dstfile);
		if ($srcX > 0 && $srcY > 0 && $dstX > 0 && $dstY > 0
			&& -f $srcfile && -f $dstfile) { #found map and valid corrdinates	
			if ($seq) {
				message TF("Recorded new portal (destination): %s (%s, %s) -> %s (%s, %s) [%s]\n", $srcMap, $srcX, $srcY, $dstMap, $dstX, $dstY, $seq), "portalRecord";
				
				FileParsers::updatePortalLUT2(Settings::getTableFilename("portals.txt"),
					$srcMap, $srcX, $srcY,
					$dstMap, $dstX, $dstY,
					$seq);		
			} else {
				message TF("Recorded new portal (destination): %s (%s, %s) -> %s (%s, %s)\n", $srcMap, $srcX, $srcY, $dstMap, $dstX, $dstY), "portalRecord";
				
				FileParsers::updatePortalLUT(Settings::getTableFilename("portals.txt"),
					$srcMap, $srcX, $srcY,
					$dstMap, $dstX, $dstY);		
			}
		}
	}
}

sub cmdPrivateMessage {
	if (!$net || $net->getState() != Network::IN_GAME) {
		error TF("You must be logged in the game to use this command '%s'\n", shift);
		return;
	}
	my ($switch, $args) = @_;
	my ($user, $msg) = parseArgs($args, 2);

	if ($user eq "" || $msg eq "") {
		error T("Syntax Error in function 'pm' (Private Message)\n" .
			"Usage: pm (username) (message)\n       pm (<#>) (message)\n");
		return;

	} elsif ($user =~ /^\d+$/) {
		if ($user - 1 >= @privMsgUsers) {
			error TF("Error in function 'pm' (Private Message)\n" .
				"Quick look-up %s does not exist\n", $user);
		} elsif (!@privMsgUsers) {
			error T("Error in function 'pm' (Private Message)\n" .
				"You have not pm-ed anyone before\n");
		} else {
			$lastpm{msg} = $msg;
			$lastpm{user} = $privMsgUsers[$user - 1];
			sendMessage($messageSender, "pm", $msg, $privMsgUsers[$user - 1]);
		}

	} else {
		if (!defined binFind(\@privMsgUsers, $user)) {
			push @privMsgUsers, $user;
		}
		$lastpm{msg} = $msg;
		$lastpm{user} = $user;
		sendMessage($messageSender, "pm", $msg, $user);
	}
}

sub cmdQuit {
	quit();
}

sub cmdReload {
	my (undef, $args) = @_;
	if ($args eq '') {
		error T("Syntax Error in function 'reload' (Reload Configuration Files)\n" .
			"Usage: reload <name|\"all\">\n");
	} else {
		parseReload($args);
	}
}

sub cmdReloadCode {
	my (undef, $args) = @_;
	if ($args ne "") {
		Modules::addToReloadQueue(parseArgs($args));
	} else {
		Modules::reloadFile("$FindBin::RealBin/src/functions.pl");
	}
}

sub cmdReloadCode2 {
	my (undef, $args) = @_;
	if ($args ne "") {
		($args =~ /\.pm$/)?Modules::addToReloadQueue2($args):Modules::addToReloadQueue2($args.".pm");
	} else {
		Modules::reloadFile("$FindBin::RealBin/src/functions.pl");
	}
}

sub cmdRelog {
	my (undef, $arg) = @_;
	if (!$arg || $arg =~ /^\d+$/) {
		@cmdQueueList = ();
		$cmdQueue = 0;
		relog($arg);
	} elsif ($arg =~ /^\d+\.\.\d+$/) {
		# range support
		my @numbers = split(/\.\./, $arg);
		if ($numbers[0] > $numbers[1]) {
			error T("Invalid range in function 'relog'\n");
		} else {
			@cmdQueueList = ();
			$cmdQueue = 0;
			relog(rand($numbers[1] - $numbers[0])+$numbers[0]);
		}
	} else {
		error T("Syntax Error in function 'relog' (Log out then log in.)\n" .
			"Usage: relog [delay]\n");
	}
}

sub cmdRepair {
	if (!$net || $net->getState() != Network::IN_GAME) {
		error TF("You must be logged in the game to use this command '%s'\n", shift);
		return;
	}
	my (undef, $listID) = @_;
	if ($listID =~ /^\d+$/) {
		if ($repairList->[$listID]) {
			$messageSender->sendRepairItem($repairList->[$listID]);
			my $name = itemNameSimple($repairList->[$listID]);
			message TF("Attempting to repair item: %s\n", $name);
		} else {
			error TF("Item with index: %s does either not exist in the 'Repair List' or the list is empty.\n", $listID);
		}
	} else {
		error T("Syntax Error in function 'repair' (Repair player's items.)\n" .
			"Usage: repair [Repair List index]\n");
	}
}

sub cmdRespawn {
	if (!$net || $net->getState() != Network::IN_GAME) {
		error TF("You must be logged in the game to use this command '%s'\n", shift);
		return;
	}
	if ($char->{dead}) {
		$messageSender->sendRestart(0);
	} else {
		main::useTeleport(2);
	}
}

sub cmdSell {
	if (!$net || $net->getState() != Network::IN_GAME) {
		error TF("You must be logged in the game to use this command '%s'\n", shift);
		return;
	}
	my @args = parseArgs($_[1]);

	if ($args[0] eq "" && $ai_v{'npc_talk'}{'talk'} eq 'buy_or_sell') {
		$messageSender->sendNPCBuySellList($talk{ID}, 1);

	} elsif ($args[0] eq "list") {
		if (@sellList == 0) {
			message T("Your sell list is empty.\n"), "info";
		} else {
			my $msg = center(T(" Sell List "), 41, '-') ."\n".
				T("#   Item                           Amount\n");
			foreach my $item (@sellList) {
				$msg .= sprintf("%-3d %-30s %d\n", $item->{binID}, $item->{name}, $item->{amount});
			}
			$msg .= ('-'x41) . "\n";
			message $msg, "list";
		}

	} elsif ($args[0] eq "done") {
		completeNpcSell(\@sellList);
		@sellList = ();
		message TF("Sold %s items.\n", @sellList.""), "success";
		
	} elsif ($args[0] eq "cancel") {
		@sellList = ();
		completeNpcSell(\@sellList);
		message T("Sell list has been cleared.\n"), "info";

	} elsif ($args[0] eq "" || ($args[0] !~ /^\d+$/ && $args[0] !~ /[,\-]/)) {
		error T("Syntax Error in function 'sell' (Sell Inventory Item)\n" .
			"Usage: sell <inventory item index #> [<amount>]\n" .
			"       sell list\n" .
			"       sell done\n" .
			"       sell cancel\n");

	} else {
		my @items = Actor::Item::getMultiple($args[0]);
		if (@items > 0) {
			foreach my $item (@items) {
				my %obj;

				if (defined(findIndex(\@sellList, "binID", $item->{binID}))) {
					error TF("%s (%s) is already in the sell list.\n", $item->nameString, $item->{binID});
					next;
				}

				$obj{name} = $item->nameString();
				$obj{ID} = $item->{ID};
				$obj{binID} = $item->{binID};
				if (!$args[1] || $args[1] > $item->{amount}) {
					$obj{amount} = $item->{amount};
				} else {
					$obj{amount} = $args[1];
				}
				push @sellList, \%obj;
				message TF("Added to sell list: %s (%s) x %s\n", $obj{name}, $obj{binID}, $obj{amount}), "info";
			}
			message T("Type 'sell done' to sell everything in your sell list.\n"), "info";

		} else {
			error TF("Error in function 'sell' (Sell Inventory Item)\n" .
				"'%s' is not a valid item index #; no item has been added to the sell list.\n",
				$args[0]);
		}
	}
}

sub cmdSendRaw {
	if (!$net || $net->getState() == Network::NOT_CONNECTED) {
		error TF("You must be connected to the server to use this command (%s)\n", shift);
		return;
	}
	my (undef, $args) = @_;
	$messageSender->sendRaw($args);
}

sub cmdShopInfoSelf {
	if (!$shopstarted) {
		error T("You do not have a shop open.\n");
		return;
	}
	# FIXME: Read the packet the server sends us to determine
	# the shop title instead of using $shop{title}.
	my $msg = center(" $shop{title} ", 79, '-') ."\n".
		T("#  Name                               Type            Amount        Price  Sold\n");
	my $priceAfterSale=0;
	my $i = 1;
	for my $item (@articles) {
		next unless $item;
		$msg .= swrite(
		   "@< @<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< @<<<<<<<<<<<<<< @<<<< @>>>>>>>>>>>z @>>>>",
			[$i++, $item->{name}, $itemTypes_lut{$item->{type}}, $item->{quantity}, formatNumber($item->{price}), $item->{sold}]);
		$priceAfterSale += ($item->{quantity} * $item->{price});
	}
	$msg .= "\n" .
		TF("You have earned: %sz.\n" .
		"Current zeny:    %sz.\n" .
		"Maximum earned:  %sz.\n" .
		"Maximum zeny:    %sz.\n",
		formatNumber($shopEarned), formatNumber($char->{zeny}),
		formatNumber($priceAfterSale), formatNumber($priceAfterSale + $char->{zeny})) .
		('-'x79) . "\n";
	message $msg, "list";
}

sub cmdBuyShopInfoSelf {
	if (!@selfBuyerItemList) {
		error T("You do not have a buying shop open.\n");
		return;
	}
	# FIXME: Read the packet the server sends us to determine
	# the shop title instead of using $shop{title}.
	my $msg = center(" Buyer Shop ", 72, '-') ."\n".
		T("#   Name                               Type           Amount       Price\n");
	my $index = 0;
	for my $item (@selfBuyerItemList) {
		next unless $item;
		$msg .= swrite(
			"@<< @<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< @<<<<<<<<<<<<< @>>>>> @>>>>>>>>>z",
			[$index, $item->{name}, $itemTypes_lut{$item->{type}}, $item->{amount}, formatNumber($item->{price})]);
	}
	$msg .= ('-'x72) . "\n";
	message $msg, "list";
}

sub cmdSit {
	if (!$net || $net->getState() != Network::IN_GAME) {
		error TF("You must be logged in the game to use this command '%s'\n", shift);
		return;
	}
	$ai_v{sitAuto_forcedBySitCommand} = 1;
	AI::clear("move", "route", "mapRoute");
	AI::clear("attack") unless ai_getAggressives();
	require Task::SitStand;
	my $task = new Task::ErrorReport(
		task => new Task::SitStand(
			actor => $char,
			mode => 'sit',
			priority => Task::USER_PRIORITY
		)
	);
	$taskManager->add($task);
	$ai_v{sitAuto_forceStop} = 0;
}

sub cmdSkills {
	my (undef, $args) = @_;
	my ($arg1) = $args =~ /^(\w+)/;
	my ($arg2) = $args =~ /^\w+ (\d+)/;
	if ($arg1 eq "") {
		if (!$char || !$char->{skills}) {
			error T("Syntax Error in function 'skills' (Skills Functions)\n" .
			"Skills list is not ready yet.\n");
			return;
		}
		my $msg = center(T(" Skill List "), 51, '-') ."\n".
			T("   # Skill Name                          Lv      SP\n");
		for my $handle (@skillsID) {
			my $skill = new Skill(handle => $handle);
			my $sp = $char->{skills}{$handle}{sp} || '';
			$msg .= swrite(
				"@>>> @<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< @>>    @>>>",
				[$skill->getIDN(), $skill->getName(), $char->getSkillLevel($skill), $sp]);
		}
		$msg .= TF("\nSkill Points: %d\n", $char->{points_skill});
		$msg .= ('-'x51) . "\n";
		message $msg, "list";

	} elsif ($arg1 eq "add" && $arg2 =~ /\d+/) {
		if (!$net || $net->getState() != Network::IN_GAME) {
			error TF("You must be logged in the game to use this command '%s'\n", 'skills add');
			return;
		}
		my $skill = new Skill(idn => $arg2);
		if (!$skill->getIDN() || !$char->{skills}{$skill->getHandle()}) {
			error TF("Error in function 'skills add' (Add Skill Point)\n" .
				"Skill %s does not exist.\n", $arg2);
		} elsif ($char->{points_skill} < 1) {
			error TF("Error in function 'skills add' (Add Skill Point)\n" .
				"Not enough skill points to increase %s\n", $skill->getName());
		} elsif ($char->{skills}{$skill->getHandle()}{up} == 0) {
			error TF("Error in function 'skills add' (Add Skill Point)\n" .
				"Skill %s reached its maximum level or prerequisite not reached\n", $skill->getName());
		} else {
			$messageSender->sendAddSkillPoint($skill->getIDN());
		}

	} elsif ($arg1 eq "desc" && $arg2 =~ /\d+/) {
		my $skill = new Skill(idn => $arg2);
		if (!$skill->getIDN()) {
			error TF("Error in function 'skills desc' (Skill Description)\n" .
				"Skill %s does not exist.\n", $arg2);
		} else {
			my $description = $skillsDesc_lut{$skill->getHandle()} || T("Error: No description available.\n");
			my $msg = center(T(" Skill Description "), 79, '=') ."\n".
						TF("Skill: %s\n\n", $skill->getName());
			$msg .= $description;
			$msg .= ('='x79) . "\n";
		message $msg, "info";
		}
	} else {
		error T("Syntax Error in function 'skills' (Skills Functions)\n" .
			"Usage: skills [<add | desc>] [<skill #>]\n");
	}
}

sub cmdSpells {
	my $msg = center(T(" Area Effects List "), 55, '-') ."\n".
			T("  # Type                 Source                   X   Y\n");
	for my $ID (@spellsID) {
		my $spell = $spells{$ID};
		next unless $spell;

		$msg .=  sprintf("%3d %-20s %-20s   %3d %3d\n", 
				$spell->{binID}, getSpellName($spell->{type}), main::getActorName($spell->{sourceID}), $spell->{pos}{x}, $spell->{pos}{y});
	}
	$msg .= ('-'x55) . "\n";
	message $msg, "list";
}

sub cmdStand {
	if (!$net || $net->getState() != Network::IN_GAME) {
		error TF("You must be logged in the game to use this command '%s'\n", shift);
		return;
	}
	delete $ai_v{sitAuto_forcedBySitCommand};
	$ai_v{sitAuto_forceStop} = 1;
	require Task::SitStand;
	my $task = new Task::ErrorReport(
		task => new Task::SitStand(
			actor => $char,
			mode => 'stand',
			priority => Task::USER_PRIORITY
		)
	);
	$taskManager->add($task);
}

sub cmdStatAdd {
	cmdStats("st", "add ".$_[1]);
}

sub cmdStats {
	if (!$char) {
		error T("Character stats information not yet available.\n");
		return;
	}
	
	my ($subcmd, $arg) = parseArgs($_[1], 2);
	
	if ($subcmd eq "add") {
		if (!$net || $net->getState() != Network::IN_GAME) {
			error TF("You must be logged in the game to use this command 'st add'\n");
			return;
		}
		
		if ($arg ne "str" && $arg ne "agi" && $arg ne "vit" && $arg ne "int" && $arg ne "dex" && $arg ne "luk") {
			error T("Syntax Error in function 'st add' (Add Status Point)\n" .
				"Usage: st add <str | agi | vit | int | dex | luk>\n");

		} elsif ($char->{$arg} >= 99 && !$config{statsAdd_over_99}) {
			error T("Error in function 'st add' (Add Status Point)\n" .
				"You cannot add more stat points than 99\n");

		} elsif ($char->{"points_$arg"} > $char->{'points_free'}) {
			error TF("Error in function 'st add' (Add Status Point)\n" .
				"Not enough status points to increase %s\n", $arg);

		} else {
			my $ID;
			if ($arg eq "str") {
				$ID = STATUS_STR;
			} elsif ($arg eq "agi") {
				$ID = STATUS_AGI;
			} elsif ($arg eq "vit") {
				$ID = STATUS_VIT;
			} elsif ($arg eq "int") {
				$ID = STATUS_INT;
			} elsif ($arg eq "dex") {
				$ID = STATUS_DEX;
			} elsif ($arg eq "luk") {
				$ID = STATUS_LUK;
			}

			$char->{$arg} += 1;
			$messageSender->sendAddStatusPoint($ID);
		}
	} else {
		my $guildName = $char->{guild} ? $char->{guild}{name} : T("None");
		my $msg = center(T(" Char Stats "), 44, '-') ."\n".
			swrite(TF(
			"Str: \@<<+\@<< #\@< Atk:  \@<<+\@<< Def:  \@<<+\@<<\n" .
			"Agi: \@<<+\@<< #\@< Matk: \@<<\@\@<< Mdef: \@<<+\@<<\n" .
			"Vit: \@<<+\@<< #\@< Hit:  \@<<     Flee: \@<<+\@<<\n" .
			"Int: \@<<+\@<< #\@< Critical: \@<< Aspd: \@<<\n" .
			"Dex: \@<<+\@<< #\@< Status Points: \@<<<\n" .
			"Luk: \@<<+\@<< #\@< Guild: \@<<<<<<<<<<<<<<<<<<<<<<<\n\n" .
			"Hair color: \@<<<<<<<<<<<<<<<<<\n" .
			"Walk speed: %.2f secs per block", $char->{walk_speed}),
			[$char->{'str'}, $char->{'str_bonus'}, $char->{'points_str'}, $char->{'attack'}, $char->{'attack_bonus'}, $char->{'def'}, $char->{'def_bonus'},
			$char->{'agi'}, $char->{'agi_bonus'}, $char->{'points_agi'}, $char->{'attack_magic_min'}, '~', $char->{'attack_magic_max'}, $char->{'def_magic'}, $char->{'def_magic_bonus'},
			$char->{'vit'}, $char->{'vit_bonus'}, $char->{'points_vit'}, $char->{'hit'}, $char->{'flee'}, $char->{'flee_bonus'},
			$char->{'int'}, $char->{'int_bonus'}, $char->{'points_int'}, $char->{'critical'}, $char->{'attack_speed'},
			$char->{'dex'}, $char->{'dex_bonus'}, $char->{'points_dex'}, $char->{'points_free'},
			$char->{'luk'}, $char->{'luk_bonus'}, $char->{'points_luk'}, $guildName,
			"$haircolors{$char->{hair_color}} ($char->{hair_color})"]);

		$msg .= T("You are sitting.\n") if $char->{sitting};
		$msg .= ('-'x44) . "\n";
		message $msg, "info";
	}
}

sub cmdStatus {
	# Display character status
	my ($baseEXPKill, $jobEXPKill);

	if (!$char) {
		error T("Character status information not yet available.\n");
		return;
	}

	if ($char->{'exp_last'} > $char->{'exp'}) {
		$baseEXPKill = $char->{'exp_max_last'} - $char->{'exp_last'} + $char->{'exp'};
	} elsif ($char->{'exp_last'} == 0 && $char->{'exp_max_last'} == 0) {
		$baseEXPKill = 0;
	} else {
		$baseEXPKill = $char->{'exp'} - $char->{'exp_last'};
	}
	if ($char->{'exp_job_last'} > $char->{'exp_job'}) {
		$jobEXPKill = $char->{'exp_job_max_last'} - $char->{'exp_job_last'} + $char->{'exp_job'};
	} elsif ($char->{'exp_job_last'} == 0 && $char->{'exp_job_max_last'} == 0) {
		$jobEXPKill = 0;
	} else {
		$jobEXPKill = $char->{'exp_job'} - $char->{'exp_job_last'};
	}


	my ($hp_string, $sp_string, $base_string, $job_string, $weight_string, $job_name_string, $zeny_string);

	$hp_string = $char->{'hp'}."/".$char->{'hp_max'}." ("
		.int($char->{'hp'}/$char->{'hp_max'} * 100)
		."%)" if $char->{'hp_max'};
	$sp_string = $char->{'sp'}."/".$char->{'sp_max'}." ("
		.int($char->{'sp'}/$char->{'sp_max'} * 100)
		."%)" if $char->{'sp_max'};
	$base_string = formatNumber($char->{'exp'})."/".formatNumber($char->{'exp_max'})." /$baseEXPKill ("
		.sprintf("%.2f",$char->{'exp'}/$char->{'exp_max'} * 100)
		."%)"
		if $char->{'exp_max'};
	$job_string = formatNumber($char->{'exp_job'})."/".formatNumber($char->{'exp_job_max'})." /$jobEXPKill ("
		.sprintf("%.2f",$char->{'exp_job'}/$char->{'exp_job_max'} * 100)
		."%)"
		if $char->{'exp_job_max'};
	$weight_string = $char->{'weight'}."/".$char->{'weight_max'} .
		" (" . sprintf("%.1f", $char->{'weight'}/$char->{'weight_max'} * 100)
		. "%)"
		if $char->{'weight_max'};
	$job_name_string = "$jobs_lut{$char->{'jobID'}} ($sex_lut{$char->{'sex'}})";
	$zeny_string = formatNumber($char->{'zeny'}) if (defined($char->{'zeny'}));

	my $dmgpsec_string = sprintf("%.2f", $dmgpsec);
	my $totalelasped_string = sprintf("%.2f", $totalelasped);
	my $elasped_string = sprintf("%.2f", $elasped);

	my $msg = center(T(" Status "), 56, '-') ."\n" .
		swrite(
		TF("\@<<<<<<<<<<<<<<<<<<<<<<<         HP: \@>>>>>>>>>>>>>>>>>>\n" .
		"\@<<<<<<<<<<<<<<<<<<<<<<<         SP: \@>>>>>>>>>>>>>>>>>>\n" .
		"Base: \@<<    \@>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>\n" .
		"Job : \@<<    \@>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>\n" .
		"Zeny: \@<<<<<<<<<<<<<<<<<     Weight: \@>>>>>>>>>>>>>>>>>>\n" .
		"Statuses: %s\n" .
		"Spirits/Coins/Amulets: %s\n\n" .
		"Total Damage: \@<<<<<<<<<<<<< Dmg/sec: \@<<<<<<<<<<<<<<\n" .
		"Total Time spent (sec): \@>>>>>>>>\n" .
		"Last Monster took (sec): \@>>>>>>>",
		$char->statusesString, (exists $char->{spirits} && $char->{spirits} != 0 ? ($char->{amuletType} ? $char->{spirits} . "\tType: " . $char->{amuletType} : $char->{spirits}) : 0)),
		[$char->{'name'}, $hp_string, $job_name_string, $sp_string,
		$char->{'lv'}, $base_string, $char->{'lv_job'}, $job_string, $zeny_string, $weight_string,
		$totaldmg, $dmgpsec_string, $totalelasped_string, $elasped_string]).
		('-'x56) . "\n";

	message $msg, "info";
}

sub cmdStorage {
	if ($char->storage->wasOpenedThisSession()) {
		my (undef, $args) = @_;

		my ($switch, $items) = split(' ', $args, 2);
		if (!$switch || $switch eq 'eq' || $switch eq 'u' || $switch eq 'nu') {
			cmdStorage_list($switch);
		} elsif ($switch eq 'log') {
			cmdStorage_log();
		} elsif ($switch eq 'desc') {
			cmdStorage_desc($items);
		} elsif (($switch =~ /^(add|addfromcart|get|gettocart)$/ && ($items || $args =~ /$switch 0/)) || $switch eq 'close') {
			if ($char->storage->isReady()) {
				if ($switch eq 'add') {
					cmdStorage_add($items);
				} elsif ($switch eq 'addfromcart') {
					cmdStorage_addfromcart($items);
				} elsif ($switch eq 'get') {
					cmdStorage_get($items);
				} elsif ($switch eq 'gettocart') {
					cmdStorage_gettocart($items);
				} elsif ($switch eq 'close') {
					cmdStorage_close();
				}
			} else {
				error T("Cannot get/add/close storage because storage is not opened\n");
			}
		} else {
			error T("Syntax Error in function 'storage' (Storage Functions)\n" .
				"Usage: storage [<eq|u|nu>]\n" .
				"       storage close\n" .
				"       storage add <inventory_item> [<amount>]\n" .
				"       storage addfromcart <cart_item> [<amount>]\n" .
				"       storage get <storage_item> [<amount>]\n" .
				"       storage gettocart <storage_item> [<amount>]\n" .
				"       storage desc <storage_item_#>\n".
				"       storage log\n");
		}
	} else {
		error T("No information about storage; it has not been opened before in this session\n");
	}
}

sub cmdStorage_add {
	my $items = shift;

	my ( $name, $amount );
	if ( $items =~ /^[^"'].* .+$/ ) {
		# Backwards compatibility: "storage add Empty Bottle 1" still works.
		( $name, $amount ) = $items =~ /^(.*?)(?: (\d+))?$/;
	} else {
		( $name, $amount ) = parseArgs( $items );
	}
	my @items = $char->inventory->getMultiple( $name );
	if ( !@items ) {
		error TF( "Inventory item '%s' does not exist.\n", $name );
		return;
	}

	transferItems( \@items, $amount, 'inventory' => 'storage' );
}

sub cmdStorage_addfromcart {
	my $items = shift;

	if (!$char->cart->isReady) {
		error T("Error in function 'storage_gettocart' (Cart Management)\nYou do not have a cart.\n");
		return;
	}

	my ( $name, $amount );
	if ( $items =~ /^[^"'].* .+$/ ) {
		# Backwards compatibility: "storage addfromcart Empty Bottle 1" still works.
		( $name, $amount ) = $items =~ /^(.*?)(?: (\d+))?$/;
	} else {
		( $name, $amount ) = parseArgs( $items );
	}
	my @items = $char->cart->getMultiple( $name );
	if ( !@items ) {
		error TF( "Cart item '%s' does not exist.\n", $name );
		return;
	}

	transferItems( \@items, $amount, 'cart' => 'storage' );
}

sub cmdStorage_get {
	my $items = shift;

	my ( $name, $amount );
	if ( $items =~ /^[^"'].* .+$/ ) {
		# Backwards compatibility: "storage get Empty Bottle 1" still works.
		( $name, $amount ) = $items =~ /^(.*?)(?: (\d+))?$/;
	} else {
		( $name, $amount ) = parseArgs( $items );
	}
	my @items = $char->storage->getMultiple( $name );
	if ( !@items ) {
		error TF( "Storage item '%s' does not exist.\n", $name );
		return;
	}

	transferItems( \@items, $amount, 'storage' => 'inventory' );
}

sub cmdStorage_gettocart {
	my $items = shift;

	if ( !$char->cart->isReady ) {
		error T( "Error in function 'storage_gettocart' (Cart Management)\nYou do not have a cart.\n" );
		return;
	}

	my ( $name, $amount );
	if ( $items =~ /^[^"'].* .+$/ ) {
		# Backwards compatibility: "storage get Empty Bottle 1" still works.
		( $name, $amount ) = $items =~ /^(.*?)(?: (\d+))?$/;
	} else {
		( $name, $amount ) = parseArgs( $items );
	}
	my @items = $char->storage->getMultiple( $name );
	if ( !@items ) {
		error TF( "Storage item '%s' does not exist.\n", $name );
		return;
	}

	transferItems( \@items, $amount, 'storage' => 'cart' );
}

sub cmdStorage_close {
	$messageSender->sendStorageClose();
}

sub cmdStorage_log {
	writeStorageLog(1);
}

sub cmdStorage_desc {
	my $items = shift;
	my $item = Match::storageItem($items);
	if (!$item) {
		error TF("Error in function 'storage desc' (Show Storage Item Description)\n" .
			"Storage Item %s does not exist.\n", $items);
	} else {
		printItemDesc($item->{nameID});
	}
}

sub cmdStore {
	my (undef, $args) = @_;
	my ($arg1) = $args =~ /^(\w+)/;
	my ($arg2) = $args =~ /^\w+ (\d+)/;

	if ($arg1 eq "" && $ai_v{'npc_talk'}{'talk'} ne 'buy_or_sell') {
		my $msg = center(TF(" Store List (%s) ", $storeList->{npcName}), 54, '-') ."\n".
			T("#  Name                    Type                  Price\n");
		foreach my $item (@$storeList) {
			$msg .= swrite(
				"@< @<<<<<<<<<<<<<<<<<<<<<< @<<<<<<<<<<<<<  @>>>>>>>>>z",
				[$item->{binID}, $item->{name}, $itemTypes_lut{$item->{type}}, $item->{price}]);
		}
		$msg .= "Store list is empty.\n" if !$storeList->size;
		$msg .= ('-'x54) . "\n";
		message $msg, "list";

	} elsif ($arg1 eq "" && $ai_v{'npc_talk'}{'talk'} eq 'buy_or_sell'
	 && ($net && $net->getState() == Network::IN_GAME)) {
		$messageSender->sendNPCBuySellList($talk{'ID'}, 0);

	} elsif ($arg1 eq "desc" && $arg2 =~ /\d+/ && !$storeList->get($arg2)) {
		error TF("Error in function 'store desc' (Store Item Description)\n" .
			"Store item %s does not exist\n", $arg2);
	} elsif ($arg1 eq "desc" && $arg2 =~ /\d+/) {
		printItemDesc($storeList->get($arg2)->{nameID});

	} else {
		error T("Syntax Error in function 'store' (Store Functions)\n" .
			"Usage: store [<desc>] [<store item #>]\n");
	}
}

sub cmdSwitchConf {
	my (undef, $filename) = @_;
	if (!defined $filename) {
		error T("Syntax Error in function 'switchconf' (Switch Configuration File)\n" .
			"Usage: switchconf <filename>\n");
	} elsif (! -f $filename) {
		error TF("Syntax Error in function 'switchconf' (Switch Configuration File)\n" .
			"File %s does not exist.\n", $filename);
	} else {
		switchConfigFile($filename);
		message TF("Switched config file to \"%s\".\n", $filename), "system";
	}
}

sub cmdTake {
	my (undef, $arg1) = @_;
	if ($arg1 eq "") {
		error T("Syntax Error in function 'take' (Take Item)\n" .
			"Usage: take <item #>\n");
	} elsif ($arg1 eq "first" && scalar(keys(%items)) == 0) {
		error T("Error in function 'take first' (Take Item)\n" .
			"There are no items near.\n");
	} elsif ($arg1 eq "first") {
		my @keys = keys %items;
		AI::take($keys[0]);
	} elsif (!$itemsID[$arg1]) {
		error TF("Error in function 'take' (Take Item)\n" .
			"Item %s does not exist.\n", $arg1);
	} else {
		main::take($itemsID[$arg1]);
	}
}

sub cmdTalk {
	if (!$net || $net->getState() != Network::IN_GAME) {
		error TF("You must be logged in the game to use this command '%s'\n", shift);
		return;
	}
	my (undef, $args) = @_;
	
	if ($args =~ /^resp$/) {
		if (!$talk{'responses'}) {
			error T("Error in function 'talk resp' (Respond to NPC)\n" .
				"No NPC response list available.\n");
			return;
					
		} else {
			my $msg = center(T(" Responses (").getNPCName($talk{ID}).") ", 40, '-') ."\n" .
				TF("#  Response\n");
			for (my $i = 0; $i < @{$talk{'responses'}}; $i++) {
				$msg .= swrite(
				"@< @*",
				[$i, $talk{responses}[$i]]);
			}
			$msg .= ('-'x40) . "\n";
			message $msg, "list";
			return;
		}
	}
	
	my @steps = split(/\s*,\s*/, $args);
	
	if (!@steps) {
		error T("Syntax Error in function 'talk' (Talk to NPC)\n" .
			"Usage: talk <NPC # | \"NPC name\" | cont | resp | num | text > [<response #>|<number #>]\n");
		return;
	}
	
	my $steps_string = "";
	my $nameID;
	foreach my $index (0..$#steps) {
		my $step = $steps[$index];
		my $type;
		my $arg;
		if ($step =~ /^(cont|text|num|resp|\d+|"[^"]+")\s+(\S.*)$/) {
			$type = $1;
			$arg = $2;
		} else {
			$type = $step;
		}
		
		my $current_step;
		
		if ($type =~ /^\d+|"([^"]+)"$/) {
			$type = $1 if $1;
			if (AI::is("NPC")) {
				error "Error in function 'talk' (Talk to NPC)\n" .
					"You are already talking with an npc\n";
				return;
			
			} elsif ($index != 0) {
				error "Error in function 'talk' (Talk to NPC)\n" .
					"You cannot start a conversation during one\n";
				return;
			
			} else {
				my $npc = $npcsList->get($type);
				if ($npc) {
					$nameID = $npc->{nameID};
				} else {
					error "Error in function 'talk' (Talk to NPC)\n" .
						"Given npc not found\n";
					return;
				}
			}
		
		} elsif (!AI::is("NPC") && !defined $nameID) {
			error "Error in function 'talk' (Talk to NPC)\n" .
				"You are not talkning to an npc\n";
			return;
		
		} elsif ($type eq "resp") {
			if ($arg =~ /^(\/(.*?)\/(\w?))$/) {
				$current_step = 'r~'.$1;
				
			} elsif ($arg =~ /^\d+$/) {
				$current_step = 'r'.$arg;
			
			} elsif (!$arg) {
				error T("Error in function 'talk resp' (Respond to NPC)\n" .
					"You must specify a response.\n");
				return;
			
			} else {
				error T("Error in function 'talk resp' (Respond to NPC)\n" .
					"Wrong talk resp sintax.\n");
				return;
			}
			
		} elsif ($type eq "num") {
			if ($arg eq "") {
				error T("Error in function 'talk num' (Respond to NPC)\n" .
					"You must specify a number.\n");
				return;
				
			} elsif ($arg !~ /^-?\d+$/) {
				error TF("Error in function 'talk num' (Respond to NPC)\n" .
					"%s is not a valid number.\n", $arg);
				return;
				
			} elsif ($arg =~ /^-?\d+$/) {
				$current_step = 'd'.$arg;
			}

		} elsif ($type eq "text") {
			if ($args eq "") {
				error T("Error in function 'talk text' (Respond to NPC)\n" .
					"You must specify a string.\n");
				return;
				
			} else {
				$current_step = 't='.$arg;
			}

		} elsif ($type eq "cont") {
			$current_step = 'c';

		} elsif ($type eq "no") {
			$current_step = 'n';
		}
			
		if (defined $current_step) {
			$steps_string .= $current_step;
			
		} elsif (!(defined $nameID && $index == 0)) {
			error T("Syntax Error in function 'talk' (Talk to NPC)\n" .
				"Usage: talk <NPC # | \"NPC name\" | cont | resp | num | text > [<response #>|<number #>]\n");
			return;
		}
			
		last if ($index == $#steps);
			
	} continue {
		$steps_string .= " " unless (defined $nameID && $index == 0);
	}
	if (defined $nameID) {
		AI::clear("route");
		AI::queue("NPC", new Task::TalkNPC(type => 'talk', nameID => $nameID, sequence => $steps_string));
	} else {
		my $task = $char->args;
		$task->addSteps($steps_string);
	}
}

sub cmdTalkNPC {
	my (undef, $args) = @_;

	my ($x, $y, $sequence) = $args =~ /^(\d+) (\d+)(?: (.+))?$/;
	unless (defined $x) {
		error T("Syntax Error in function 'talknpc' (Talk to an NPC)\n" .
			"Usage: talknpc <x> <y> <sequence>\n");
		return;
	}

	message TF("Talking to NPC at (%d, %d) using sequence: %s\n", $x, $y, $sequence);
	main::ai_talkNPC($x, $y, $sequence);
}

sub cmdTank {
	my (undef, $arg) = @_;
	$arg =~ s/ .*//;

	if ($arg eq "") {
		error T("Syntax Error in function 'tank' (Tank for a Player/Slave)\n" .
			"Usage: tank <player #|player name|\@homunculus|\@mercenary>\n");

	} elsif ($arg eq "stop") {
		configModify("tankMode", 0);

	} elsif ($arg =~ /^\d+$/) {
		if (!$playersID[$arg]) {
			error TF("Error in function 'tank' (Tank for a Player)\n" .
				"Player %s does not exist.\n", $arg);
		} else {
			configModify("tankMode", 1);
			configModify("tankModeTarget", $players{$playersID[$arg]}{name});
		}

	} else {
		my $name;
		for (@$playersList, @$slavesList) {
			if (lc $_->{name} eq lc $arg) {
				$name = $_->{name};
				last;
			} elsif($char->{homunculus} && $_->{ID} eq $char->{homunculus}{ID} && $arg eq '@homunculus' ||
					$char->{mercenary} && $_->{ID} eq $char->{mercenary}{ID} && $arg eq '@mercenary') {
					$name = $arg;
				last;
			}
		}

		if ($name) {
			configModify("tankMode", 1);
			configModify("tankModeTarget", $name);
		} else {
			error TF("Error in function 'tank' (Tank for a Player/Slave)\n" .
				"Player/Slave %s does not exist.\n", $arg);
		}
	}
}

sub cmdTeleport {
	if (!$net || $net->getState() != Network::IN_GAME) {
		error TF("You must be logged in the game to use this command '%s'\n", shift);
		return;
	}
	my (undef, $args) = @_;
	my ($arg1) = $args =~ /^(\d)/;
	$arg1 = 1 unless $arg1;
	main::useTeleport($arg1);
}

sub cmdTestShop {
	my @items = main::makeShop();
	return unless @items;
	my @shopnames = split(/;;/, $shop{title_line});
	$shop{title} = $shopnames[int rand($#shopnames + 1)];
	$shop{title} = ($config{shopTitleOversize}) ? $shop{title} : substr($shop{title},0,36);

	my $msg = center(" $shop{title} ", 69, '-') ."\n".
			T("Name                                           Amount           Price\n");
	for my $item (@items) {
		$msg .= swrite("@<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<  @<<<<<  @>>>>>>>>>>>>z",
			[$item->{name}, $item->{amount}, formatNumber($item->{price})]);
	}
	$msg .= "\n" . TF("Total of %d items to sell.\n", binSize(\@items)) .
			('-'x69) . "\n";
	message $msg, "list";
}

sub cmdTimeout {
	my (undef, $args) = @_;
	my ($arg1) = $args =~ /^(\w+)/;
	my ($arg2) = $args =~ /^\w+\s+([\s\S]+)\s*$/;
	if ($arg1 eq "") {
		error T("Syntax Error in function 'timeout' (set a timeout)\n" .
			"Usage: timeout <type> [<seconds>]\n");
	} elsif ($timeout{$arg1} eq "") {
		error TF("Error in function 'timeout' (set a timeout)\n" .
			"Timeout %s doesn't exist\n", $arg1);
	} elsif ($arg2 eq "") {
		message TF("Timeout '%s' is %s\n",
			$arg1, $timeout{$arg1}{timeout}), "info";
	} else {
		setTimeout($arg1, $arg2);
	}
}

sub cmdUnequip {

	# unequip an item
	my (undef, $args) = @_;
	my ($arg1,$arg2) = $args =~ /^(\S+)\s*(.*)/;
	my $slot;
	my $item;

	if ($arg1 eq "") {
		cmdEquip_list();
		return;
	}

	if ($arg1 eq "slots") {
		# Translation Comment: List of equiped items on each slot
		message T("Slots:\n") . join("\n", @Actor::Item::slots). "\n", "list";
		return;
	}

	if (!$net || $net->getState() != Network::IN_GAME) {
		error TF("You must be logged in the game to use this command '%s'\n", 'eq ' .$args);
		return;
	}

	if ($equipSlot_rlut{$arg1}) {
		$slot = $arg1;
	} else {
		$arg1 .= " $arg2" if $arg2;
	}

	$item = Actor::Item::get(defined $slot ? $arg2 : $arg1, undef, 0);

	if (!$item) {
		$args =~ s/^($slot)\s//g if ($slot);
		$slot = T("undefined") unless ($slot);
		error TF("No such equipped Inventory Item: %s in slot: %s\n", $args, $slot);
		return;
	}

	if (!$item->{type_equip} && $item->{type} != 10 && $item->{type} != 16 && $item->{type} != 17) {
		error TF("Inventory Item %s (%s) can't be unequipped.\n",
			$item->{name}, $item->{binID});
		return;
	}
	if ($slot) {
		$item->unequipFromSlot($slot);
	} else {
		$item->unequip();
	}
}

sub cmdUseItemOnMonster {
	if (!$net || $net->getState() != Network::IN_GAME) {
		error TF("You must be logged in the game to use this command '%s'\n", shift);
		return;
	}
	my (undef, $args) = @_;
	my ($arg1) = $args =~ /^(\d+)/;
	my ($arg2) = $args =~ /^\d+ (\d+)/;

	if ($arg1 eq "" || $arg2 eq "") {
		error T("Syntax Error in function 'im' (Use Item on Monster)\n" .
			"Usage: im <item #> <monster #>\n");
	} elsif (!$char->inventory->get($arg1)) {
		error TF("Error in function 'im' (Use Item on Monster)\n" .
			"Inventory Item %s does not exist.\n", $arg1);
	} elsif ($monstersID[$arg2] eq "") {
		error TF("Error in function 'im' (Use Item on Monster)\n" .
			"Monster %s does not exist.\n", $arg2);
	} else {
		$char->inventory->get($arg1)->use($monstersID[$arg2]);
	}
}

sub cmdUseItemOnPlayer {
	if (!$net || $net->getState() != Network::IN_GAME) {
		error TF("You must be logged in the game to use this command '%s'\n", shift);
		return;
	}
	my (undef, $args) = @_;
	my ($arg1) = $args =~ /^(\d+)/;
	my ($arg2) = $args =~ /^\d+ (\d+)/;
	if ($arg1 eq "" || $arg2 eq "") {
		error T("Syntax Error in function 'ip' (Use Item on Player)\n" .
			"Usage: ip <item #> <player #>\n");
	} elsif (!$char->inventory->get($arg1)) {
		error TF("Error in function 'ip' (Use Item on Player)\n" .
			"Inventory Item %s does not exist.\n", $arg1);
	} elsif ($playersID[$arg2] eq "") {
		error TF("Error in function 'ip' (Use Item on Player)\n" .
			"Player %s does not exist.\n", $arg2);
	} else {
		$char->inventory->get($arg1)->use($playersID[$arg2]);
	}
}

sub cmdUseItemOnSelf {
	if (!$net || $net->getState() != Network::IN_GAME) {
		error TF("You must be logged in the game to use this command '%s'\n", shift);
		return;
	}
	my (undef, $args) = @_;
	if ($args eq "") {
		error T("Syntax Error in function 'is' (Use Item on Yourself)\n" .
			"Usage: is <item>\n");
		return;
	}
	my $item = Actor::Item::get($args);
	if (!$item) {
		error TF("Error in function 'is' (Use Item on Yourself)\n" .
			"Inventory Item %s does not exist.\n", $args);
		return;
	}
	$item->use;
}

sub cmdUseSkill {
	if (!$net || $net->getState() != Network::IN_GAME) {
		error TF("You must be logged in the game to use this command '%s'\n", shift);
		return;
	}
	my ($cmd, $args_string) = @_;
	my ($target, $actorList, $skill, $level) = @_;
	my @args = parseArgs($args_string);

	if ($cmd eq 'sl') {
		my ($x, $y);
		
		if (scalar @args < 3) {
			$x = $char->position->{x};
			$y = $char->position->{y};
			$level = $args[1];
		} else {
			$x = $args[1];
			$y = $args[2];
			$level = $args[3];
		}
		
		if (@args < 1 || @args > 4) {
			error T("Syntax error in function 'sl' (Use Skill on Location)\n" .
				"Usage: sl <skill #> [<x> <y>] [level]\n");
			return;
		} elsif ($x !~ /^\d+$/ || $y !~ /^\d+/) {
			error T("Error in function 'sl' (Use Skill on Location)\n" .
				"Invalid coordinates given.\n");
			return;
		} else {
			$target = { x => $x, y => $y };
		}
		# This was the code for choosing a random location when x and y are not given:
		# my $pos = calcPosition($char);
		# my @positions = calcRectArea($pos->{x}, $pos->{y}, int(rand 2) + 2);
		# $pos = $positions[rand(@positions)];
		# ($x, $y) = ($pos->{x}, $pos->{y});

	} elsif ($cmd eq 'ss') {
		if (@args < 1 || @args > 2) {
			error T("Syntax error in function 'ss' (Use Skill on Self)\n" .
				"Usage: ss <skill #> [level]\n");
			return;
		} else {
			$target = $char;
			$level = $args[1];
		}

	} elsif ($cmd eq 'sp') {
		if (@args < 2 || @args > 3) {
			error T("Syntax error in function 'sp' (Use Skill on Player)\n" .
				"Usage: sp <skill #> <player #> [level]\n");
			return;
		} else {
			$target = Match::player($args[1], 1);
			if (!$target) {
				error TF("Error in function 'sp' (Use Skill on Player)\n" .
					"Player '%s' does not exist.\n", $args[1]);
				return;
			}
			$actorList = $playersList;
			$level = $args[2];
		}

	} elsif ($cmd eq 'sm') {
		if (@args < 2 || @args > 3) {
			error T("Syntax error in function 'sm' (Use Skill on Monster)\n" .
				"Usage: sm <skill #> <monster #> [level]\n");
			return;
		} else {
			$target = $monstersList->get($args[1]);
			if (!$target) {
				error TF("Error in function 'sm' (Use Skill on Monster)\n" .
					"Monster %d does not exist.\n", $args[1]);
				return;
			}
			$actorList = $monstersList;
			$level = $args[2];
		}

	} elsif ($cmd eq 'ssl') {
		if (@args < 2 || @args > 3) {
			error T("Syntax error in function 'ssl' (Use Skill on Slave)\n" .
				"Usage: ssl <skill #> <slave #> [level]\n");
			return;
		} else {
			$target = $slavesList->get($args[1]);
			if (!$target) {
				error TF("Error in function 'ssl' (Use Skill on Slave)\n" .
					"Slave %d does not exist.\n", $args[1]);
				return;
			}
			$actorList = $slavesList;
			$level = $args[2];
		}

	} elsif ($cmd eq 'ssp') {
		if (@args < 2 || @args > 3) {
			error T("Syntax error in function 'ssp' (Use Skill on Area Spell Location)\n" .
				"Usage: ssp <skill #> <spell #> [level]\n");
			return;
		}
		my $targetID = $spellsID[$args[1]];
		if (!$targetID) {
			error TF("Spell %d does not exist.\n", $args[1]);
			return;
		}
		my $pos = $spells{$targetID}{pos_to};
		$target = { %{$pos} };
	}

	$skill = new Skill(auto => $args[0], level => $level);

	require Task::UseSkill;
	my $skillTask = new Task::UseSkill(
		actor => $skill->getOwner,
		target => $target,
		actorList => $actorList,
		skill => $skill,
		priority => Task::USER_PRIORITY
	);
	my $task = new Task::ErrorReport(task => $skillTask);
	$taskManager->add($task);
}

sub cmdVender {
	if (!$net || $net->getState() != Network::IN_GAME) {
		error TF("You must be logged in the game to use this command '%s'\n", shift);
		return;
	}
	my (undef, $args) = @_;
	my ($arg1) = $args =~ /^([\d\w]+)/;
	my ($arg2) = $args =~ /^[\d\w]+ (\d+)/;
	my ($arg3) = $args =~ /^[\d\w]+ \d+ (\d+)/;
	if ($arg1 eq "") {
		error T("Syntax error in function 'vender' (Vender Shop)\n" .
			"Usage: vender <vender # | end> [<item #> <amount>]\n");
	} elsif ($arg1 eq "end") {
		$venderItemList->clear;
		undef $venderID;
		undef $venderCID;
	} elsif ($venderListsID[$arg1] eq "") {
		error TF("Error in function 'vender' (Vender Shop)\n" .
			"Vender %s does not exist.\n", $arg1);
	} elsif ($arg2 eq "") {
		$messageSender->sendEnteringVender($venderListsID[$arg1]);
	} elsif ($venderListsID[$arg1] ne $venderID) {
		error T("Error in function 'vender' (Vender Shop)\n" .
			"Vender ID is wrong.\n");
	} elsif (!$venderItemList->get( $arg2 )) {
		error TF("Error in function 'vender' (Vender Shop)\n" .
			"Item %s does not exist.\n", $arg2);
	} else {
		$arg3 = 1 if $arg3 <= 0;
		my $item = $venderItemList->get( $arg2 );
		$messageSender->sendBuyBulkVender( $venderID, [ { itemIndex => $item->{ID}, amount => $arg3 } ], $venderCID );
	}
}

sub cmdVenderList {
	my $msg = center(T(" Vender List "), 75, '-') ."\n".
		T("#    Title                                 Coords      Owner\n");
	for (my $i = 0; $i < @venderListsID; $i++) {
		next if ($venderListsID[$i] eq "");
		my $player = Actor::get($venderListsID[$i]);
		# autovivifies $obj->{pos_to} but it doesnt matter
		$msg .= sprintf(
			"%-3d  %-36s  (%3s, %3s)  %-20s\n",
			$i, $venderLists{$venderListsID[$i]}{'title'},
			$player->{pos_to}{x} || '?', $player->{pos_to}{y} || '?', $player->name);
	}
	$msg .= ('-'x75) . "\n";
	message $msg, "list";
}

sub cmdBuyerList {
	my $msg = center(T(" Buyer List "), 75, '-') ."\n".
		T("#    Title                                 Coords      Owner\n");
	for (my $i = 0; $i < @buyerListsID; $i++) {
		next if ($buyerListsID[$i] eq "");
		my $player = Actor::get($buyerListsID[$i]);
		# autovivifies $obj->{pos_to} but it doesnt matter
		$msg .= sprintf(
			"%-3d  %-36s  (%3s, %3s)  %-20s\n",
			$i, $buyerLists{$buyerListsID[$i]}{'title'},
			$player->{pos_to}{x} || '?', $player->{pos_to}{y} || '?', $player->name);
	}
	$msg .= ('-'x75) . "\n";
	message $msg, "list";
}

sub cmdBooking {
	if (!$net || $net->getState() != Network::IN_GAME) {
		error TF("You must be logged in the game to use this command '%s'\n", shift);
		return;
	}

	my (undef, $args) = @_;
	my ($arg1) = $args =~ /^(\w+)/;

	if ($arg1 eq "search") {
		$args =~ /^\w+\s([0-9]+)\s?([0-9]+)?\s?([0-9]+)?\s?([0-9]+)?\s?([0-9]+)?/;
		# $1 -> level
		# $2 -> MapID
		# $3 -> job
		# $4 -> ResultCount
		# $5 -> LastIndex

		$messageSender->sendPartyBookingReqSearch($1, $2, $3, $4, $5);
	} elsif ($arg1 eq "recruit") {
		$args =~ /^\w+\s([0-9]+)\s?([0-9]+)?\s?([0-9]+)?\s?([0-9]+)?\s?([0-9]+)?\s?([0-9]+)?\s?([0-9]+)?\s?([0-9]+)?/;
		# $1      -> level
		# $2      -> MapID
		# $3 ~ $8 -> jobs

		if (!$3) {
			error T("Syntax Error in function 'booking recruit' (Booking recruit)\n" .
				"Usage: booking recruit \"<level>\" \"<MapID>\" \"<job 1 ~ 6x>\"\n");
			return;
		}

		# job null = 65535
		my @jobList = (65535) x 6;
		$jobList[0] = $3;
		$jobList[1] = $4 if ($4);
		$jobList[2] = $5 if ($5);
		$jobList[3] = $6 if ($6);
		$jobList[4] = $7 if ($7);
		$jobList[5] = $8 if ($8);

		$messageSender->sendPartyBookingRegister($1, $2, @jobList);
	} elsif ($arg1 eq "update") {
		$args =~ /^\w+\s([0-9]+)\s?([0-9]+)?\s?([0-9]+)?\s?([0-9]+)?\s?([0-9]+)?\s?([0-9]+)?/;

		# job null = 65535
		my @jobList = (65535) x 6;
		$jobList[0] = $1;
		$jobList[1] = $2 if ($2);
		$jobList[2] = $3 if ($3);
		$jobList[3] = $4 if ($4);
		$jobList[4] = $5 if ($5);
		$jobList[5] = $6 if ($6);

		$messageSender->sendPartyBookingUpdate(@jobList);
	} elsif ($arg1 eq "delete") {
		$messageSender->sendPartyBookingDelete();
	} else {
		error T("Syntax error in function 'booking'\n" .
			"Usage: booking [<search | recruit | update | delete>]\n");
	}
}

sub cmdBuyer {
	if (!$net || $net->getState() != Network::IN_GAME) {
		error TF("You must be logged in the game to use this command '%s'\n", shift);
		return;
	}
	my (undef, $args) = @_;
	my ($arg1) = $args =~ /^([\d\w]+)/;
	my ($arg2) = $args =~ /^[\d\w]+ (\d+)/;
	my ($arg3) = $args =~ /^[\d\w]+ \d+ (\d+)/;
	if ($arg1 eq "") {
		error T("Syntax error in function 'buyer' (Buyer Shop)\n" .
			"Usage: buyer <buyer # | end> [<item #> <amount>]\n");
	} elsif ($arg1 eq "end") {
		undef @buyerItemList;
		undef $buyerID;
		undef $buyingStoreID;
	} elsif ($buyerListsID[$arg1] eq "") {
		error TF("Error in function 'buyer' (Buyer Shop)\n" .
			"buyer %s does not exist.\n", $arg1);
	} elsif ($arg2 eq "") {
		# FIXME not implemented
		undef @buyerItemList;
		undef $buyerID;
		undef $buyingStoreID;
		$messageSender->sendEnteringBuyer($buyerListsID[$arg1]);
	} elsif ($buyerListsID[$arg1] ne $buyerID) {
		error T("Error in function 'buyer' (Buyer Shop)\n" .
			"Buyer ID is wrong.\n");
	} else {
		if ($arg3 <= 0) {
			$arg3 = 1;
		}
		$messageSender->sendBuyBulkBuyer($buyerID, [{itemIndex => $arg2, itemID => $buyerItemList[$arg2]->{nameID}, amount => $arg3}], $buyingStoreID);
	}
}


sub cmdVerbose {
	if ($config{'verbose'}) {
		configModify("verbose", 0);
	} else {
		configModify("verbose", 1);
	}
}

sub cmdVersion {
	message "$Settings::versionText";
}

sub cmdWarp {
	if (!$net || $net->getState() != Network::IN_GAME) {
		error TF("You must be logged in the game to use this command '%s'\n", shift);
		return;
	}
	my (undef, $map) = @_;

	if ($map eq '') {
		error T("Error in function 'warp' (Open/List Warp Portal)\n" .
			"Usage: warp <map name | map number# | list | cancel>\n");

	} elsif ($map =~ /^\d+$/) {
		if (!$char->{warp}{memo} || !@{$char->{warp}{memo}}) {
			error T("You didn't cast warp portal.\n");
			return;
		}

		if ($map < 0 || $map > @{$char->{warp}{memo}}) {
			error TF("Invalid map number %s.\n", $map);
		} else {
			my $name = $char->{warp}{memo}[$map];
			my $rsw = "$name.rsw";
			message TF("Attempting to open a warp portal to %s (%s)\n",
				$maps_lut{$rsw}, $name), "info";
			$messageSender->sendWarpTele(27,"$name.gat");
		}

	} elsif ($map eq 'list') {
		if (!$char->{warp}{memo} || !@{$char->{warp}{memo}}) {
			error T("You didn't cast warp portal.\n");
			return;
		}

		my $msg = center(T(" Warp Portal "), 50, '-') ."\n".
			T("#  Place                           Map\n");
		for (my $i = 0; $i < @{$char->{warp}{memo}}; $i++) {
			$msg .= swrite(
				"@< @<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< @<<<<<<<<<<<<<<<",
				[$i, $maps_lut{$char->{warp}{memo}[$i].'.rsw'}, $char->{warp}{memo}[$i]]);
		}
		$msg .= ('-'x50) . "\n";
		message $msg, "list";

	} elsif ($map eq 'cancel') {
		message T("Attempting to cancel the warp portal\n"), 'info';
		$messageSender->sendWarpTele(27, 'cancel');

	} elsif (!defined $maps_lut{$map.'.rsw'}) {
		error TF("Map '%s' does not exist.\n", $map);

	} else {
		my $rsw = "$map.rsw";
		message TF("Attempting to open a warp portal to %s (%s)\n",
			$maps_lut{$rsw}, $map), "info";
		$messageSender->sendWarpTele(27,"$map.gat");
	}
}

sub cmdWeight {
	if (!$char) {
		error T("Character weight information not yet available.\n");
		return;
	}
	my (undef, $itemWeight) = @_;

	$itemWeight ||= 1;

	if ($itemWeight !~ /^\d+(\.\d+)?$/) {
		error T("Syntax error in function 'weight' (Inventory Weight Info)\n" .
			"Usage: weight [item weight]\n");
		return;
	}

	my $itemString = $itemWeight == 1 ? '' : "*$itemWeight";
	message TF("Weight: %s/%s (%s\%)\n", $char->{weight}, $char->{weight_max}, sprintf("%.02f", $char->weight_percent)), "list";
	if ($char->weight_percent < 90) {
		if ($char->weight_percent < 50) {
			my $weight_50 = int((int($char->{weight_max}*0.5) - $char->{weight}) / $itemWeight);
			message TF("You can carry %s%s before %s overweight.\n",
				$weight_50, $itemString, '50%'), "list";
		} else {
			message TF("You are %s overweight.\n", '50%'), "list";
		}
		my $weight_90 = int((int($char->{weight_max}*0.9) - $char->{weight}) / $itemWeight);
		message TF("You can carry %s%s before %s overweight.\n",
			$weight_90, $itemString, '90%'), "list";
	} else {
		message TF("You are %s overweight.\n", '90%');
	}
}

sub cmdWhere {
	if (!$char) {
		error T("Location not yet available.\n");
		return;
	}
	my $pos = calcPosition($char);
	message TF("Location: %s : (baseName: %s) : %d, %d\n", $field->descString(), $field->baseName(), $pos->{x}, $pos->{y}), "info";
}

sub cmdWho {
	if (!$net || $net->getState() != Network::IN_GAME) {
		error TF("You must be logged in the game to use this command '%s'\n", shift);
		return;
	}
	$messageSender->sendWho();
}

sub cmdWhoAmI {
	if (!$char) {
		error T("Character information not yet available.\n");
		return;
	}
	my $GID = unpack("V1", $charID);
	my $AID = unpack("V1", $accountID);
	message TF("Name:    %s (Level %s %s %s)\n" .
		"Char ID: %s\n" .
		"Acct ID: %s\n",
		$char->{name}, $char->{lv}, $sex_lut{$char->{sex}}, $jobs_lut{$char->{jobID}},
		$GID, $AID), "list";
}

sub cmdAuction {
	if (!$net || $net->getState() != Network::IN_GAME) {
		error TF("You must be logged in the game to use this command '%s'\n", shift);
		return;
	}

	my ($cmd, $args_string) = @_;
	my @args = parseArgs($args_string, 4);

	# auction add item
	# TODO: it doesn't seem possible to add more than 1 item?
	if ($cmd eq 'aua') {
		unless (defined $args[0] && $args[1] =~ /^\d+$/) {
			message T("Usage: aua (<item #>|<item name>) <amount>\n"), "info";
		} elsif (my $item = Actor::Item::get($args[0])) {
			my $serverIndex = $item->{ID};
			$messageSender->sendAuctionAddItem($serverIndex, $args[1]);
		}
	# auction remove item
	} elsif ($cmd eq 'aur') {
			$messageSender->sendAuctionAddItemCancel();
	# auction create (add item first)
	} elsif ($cmd eq 'auc') {
		unless ($args[0] && $args[1] && $args[2]) {
			message T("Usage: auc <current price> <instant buy price> <hours>\n"), "info";
		} else {
			my ($price, $buynow, $hours) = ($args[0], $args[1], $args[2]);
			$messageSender->sendAuctionCreate($price, $buynow, $hours);
		}
		# auction create (add item first)
	} elsif ($cmd eq 'aub') {
		unless (defined $args[0] && $args[1] =~ /^\d+$/) {
			message T("Usage: aub <id> <price>\n"), "info";
		} else {
			unless ($auctionList->[$args[0]]->{ID}) {
				if (@{$auctionList}) {
						message TF("No auction item found with index: %s. (might need to re-open auction window)\n", $args[0]), "info";
				} else {
						message T("Auction window has not been opened or is empty.\n"), "info";
				}
			} else {
				$messageSender->sendAuctionBuy($auctionList->[$args[0]]->{ID}, $args[1]);
			}
		}
	# auction info (my)
	} elsif ($cmd eq 'aui') {
		# funny thing is, we can access this info trough 'aus' aswell
		unless ($args[0] eq "selling" || $args[0] eq "buying") {
			message T("Usage: aui (selling|buying)\n"), "info";
		} else {
			$args[0] = ($args[0] eq "selling") ? 0 : 1;
			$messageSender->sendAuctionReqMyInfo($args[0]);
		}
	# auction delete
	} elsif ($cmd eq 'aud') {
		unless ($args[0] =~ /^\d+$/) {
			message T("Usage: aud <index>\n"), "info";
		} else {
			unless ($auctionList->[$args[0]]->{ID}) {
				if (@{$auctionList}) {
					message TF("No auction item found with index: %s. (might need to re-open auction window)\n", $args[0]), "info";
				} else {
					message T("Auction window has not been opened or is empty.\n"), "info";
				}
			} else {
				$messageSender->sendAuctionCancel($auctionList->[$args[0]]->{ID});
			}
		}
	# auction end (item gets sold to highest bidder?)
	} elsif ($cmd eq 'aue') {
		unless ($args[0] =~ /^\d+$/) {
			message T("Usage: aue <index>\n"), "info";
		} else {
			unless ($auctionList->[$args[0]]->{ID}) {
				if (@{$auctionList}) {
					message TF("No auction item found with index: %s. (might need to re-open auction window)\n", $args[0]), "info";
				} else {
					message T("Auction window has not been opened or is empty.\n"), "info";
				}
			} else {
				$messageSender->sendAuctionMySellStop($auctionList->[$args[0]]->{ID});
			}
		}
	# auction search
	} elsif ($cmd eq 'aus') {
		# TODO: can you in official servers do a query on both a category AND price/text? (eA doesn't allow you to)
		unless (defined $args[0]) {
			message T("Usage: aus <type> [<price>|<text>]\n" .
			"      types (0:Armor 1:Weapon 2:Card 3:Misc 4:By Text 5:By Price 6:Sell 7:Buy)\n"), "info";
		# armor, weapon, card, misc, sell, buy
		} elsif ($args[0] =~ /^[0-3]$/ || $args[0] =~ /^[6-7]$/) {
			$messageSender->sendAuctionItemSearch($args[0]);
		# by text
		} elsif ($args[0] == 5) {
			unless (defined $args[1]) {
				message T("Usage: aus 5 <text>\n"), "info";
			} else {
				$messageSender->sendAuctionItemSearch($args[0], undef, $args[1]);
			}
		# by price
		} elsif ($args[0] == 6) {
			unless ($args[1] =~ /^\d+$/) {
				message T("Usage: aus 6 <price>\n"), "info";
			} else {
				$messageSender->sendAuctionItemSearch($args[0], $args[1]);
			}
		} else {
			error T("Possible value's for the <type> parameter are:\n" .
					"(0:Armor 1:Weapon 2:Card 3:Misc 4:By Text 5:By Price 6:Sell 7:Buy)\n");
		}
	# with command auction, list of possebilities: $cmd eq 'au'
	} else {
		message T("Auction commands: aua, aur, auc, aub, aui, aud, aue, aus\n"), "info";
	}
}

sub cmdShowEquip {
	if (!$net || $net->getState() != Network::IN_GAME) {
		error TF("You must be logged in the game to use this command '%s'\n", shift);
		return;
	}
	my ($cmd, $args_string) = @_;
	my @args = parseArgs($args_string, 2);
	if ($args[0] eq 'p') {
		if (my $actor = Match::player($args[1], 1)) {
			$messageSender->sendShowEquipPlayer($actor->{ID});
			message TF("Requesting equipment information for: %s\n", $actor->name), "info";
		} elsif ($args[1]) {
			message TF("No player found with specified information: %s\n", $args[1]), "info";
		} else {
			message T("Usage: showeq p <index|name|partialname>\n");
		}
	} elsif ($args[0] eq 'me') {
		$messageSender->sendShowEquipTickbox($args[1] eq 'on');
	} else {
		message T("Usage: showeq [p <index|name|partialname>] | [me <on|off>]\n"), "info";
	}
}

sub cmdCooking {
	if (!$net || $net->getState() != Network::IN_GAME) {
		error TF("You must be logged in the game to use this command '%s'\n", shift);
		return;
	}
	my ($cmd, $arg) = @_;
	if ($arg =~ /^\d+/ && defined $cookingList->[$arg]) { # viewID/nameID can be 0
		$messageSender->sendCooking(1, $cookingList->[$arg]); # type 1 is for cooking
	} else {
		message TF("Item with 'Cooking List' index: %s not found.\n", $arg), "info";
	}
}

sub cmdAnswerCaptcha {
	$messageSender->sendCaptchaAnswer($_[1]);
}

### CATEGORY: Private functions

##
# void cmdStorage_list(String list_type)
# list_type: ''|eq|nu|u
#
# Displays the contents of storage, or a subset indicated by switches.
#
# Called by: cmdStorage (not called directly).
sub cmdStorage_list {
	my $type = shift;
	message "$type\n";

	my @useable;
	my @equipment;
	my @non_useable;
	my ($i, $display, $index);
	
	for my $item (@{$char->storage}) {
		if ($item->usable) {
			push @useable, $item->{binID};
		} elsif ($item->equippable) {
			my %eqp;
			$eqp{index} = $item->{ID};
			$eqp{binID} = $item->{binID};
			$eqp{name} = $item->{name};
			$eqp{amount} = $item->{amount};
			$eqp{identified} = " -- " . T("Not Identified") if !$item->{identified};
			$eqp{type} = $itemTypes_lut{$item->{type}};
			push @equipment, \%eqp;
		} else {
			push @non_useable, $item->{binID};
		}
	}

	my $msg = center(defined $storageTitle ? $storageTitle : T(' Storage '), 50, '-') . "\n";

	if (!$type || $type eq 'u') {
		$msg .= T("-- Usable --\n");
		for (my $i = 0; $i < @useable; $i++) {
			$index = $useable[$i];
			my $item = $char->storage->get($index);
			$display = $item->{name};
			$display .= " x $item->{amount}";
			$msg .= swrite(
				"@<<< @<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<",
				[$index, $display]);
		}
	}

	if (!$type || $type eq 'eq') {
		$msg .= T("\n-- Equipment --\n");
		foreach my $item (@equipment) {
			## altered to allow for Arrows/Ammo which will are stackable equip.
			$display = sprintf("%-3d  %s (%s)", $item->{binID}, $item->{name}, $item->{type});
			$display .= " x $item->{amount}" if $item->{amount} > 1;
			$display .= $item->{identified};
			$msg .= sprintf("%-57s\n", $display);
		}
	}

	if (!$type || $type eq 'nu') {
		$msg .= T("\n-- Non-Usable --\n");
		for (my $i = 0; $i < @non_useable; $i++) {
			$index = $non_useable[$i];
			my $item = $char->storage->get($index);
			$display = $item->{name};
			$display .= " x $item->{amount}";
			$msg .= swrite(
				"@<<< @<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<",
				[$index, $display]);
		}
	}

	$msg .= TF("\nCapacity: %d/%d\n", $char->storage->items, $char->storage->items_max) .
			('-'x50) . "\n";
	message $msg, "list";
}

sub cmdDeadTime {
	if (!$net || $net->getState() != Network::IN_GAME) {
		error TF("You must be logged in the game to use this command '%s'\n", shift);
		return;
	}
	my $msg;
	if (@deadTime) {
		$msg = center(T(" Dead Time Record "), 50, '-') ."\n";
		my $i = 1;
		foreach my $dead (@deadTime) {
			$msg .= "[".$i."] ". $dead."\n";
		}
		$msg .= ('-'x50) . "\n";
	} else {
		$msg = T("You have not died yet.\n");
	}
	message $msg, "list";
}

sub cmdAchieve {
	my (undef, $args) = @_;
	my ($arg1) = $args =~ /^(\w+)/;
	my ($arg2) = $args =~ /^\w+\s+(\S.*)/;
	
	if (($arg1 ne 'list' && $arg1 ne 'reward') || ($arg1 eq 'list' && defined $arg2) || ($arg1 eq 'reward' && !defined $arg2)) {
		error T("Syntax Error in function 'achieve'\n".
			"Usage: achieve [<list|reward>] [<achievemente_id>]\n".
			"Usage: achieve list: Shows all current achievements\n".
			"Usage: achieve reward achievemente_id: Request reward for the achievement of id achievemente_id\n"
			);
			
		return;
	}

	if ($arg1 eq 'reward') {
		if (!exists $achievementList->{$arg2}) {
			error TF("You don't have the achievement %s.\n", $arg2);
			
		} elsif ($achievementList->{$arg2}{completed} != 1) {
			error TF("You haven't completed the achievement %s.\n", $arg2);
		
		} elsif ($achievementList->{$arg2}{reward} == 1) {
			error TF("You have already claimed the achievement %s reward.\n", $arg2);
			
		} else {
			message TF("Sending request for reward of achievement %s.\n", $arg2);
			$messageSender->sendAchievementGetReward($arg2);
		}
	
	} elsif ($arg1 eq 'list') {
		my $msg = center(" " . "Achievement List" . " ", 79, '-') . "\n";
		my $index = 0;
		foreach my $achieve_id (keys %{$achievementList}) {
			my $achieve = $achievementList->{$achieve_id};
			$msg .= swrite(sprintf("\@%s \@%s \@%s \@%s", ('>'x2), ('<'x7), ('<'x15), ('<'x15)), [$index, $achieve_id, $achieve->{completed} ? "complete" : "incomplete", $achieve->{reward}  ? "rewarded" : "not rewarded"]);
			$index++;
		}
		$msg .= sprintf("%s\n", ('-'x79));
		message $msg, "list";
	}
}

sub cmdCancelTransaction {
	if (!$net || $net->getState() != Network::IN_GAME) {
		error TF("You must be logged in the game to use this command '%s'\n", shift);
		return;
	}
	
	if ($ai_v{'npc_talk'}{'talk'} eq 'buy_or_sell') {
		cancelNpcBuySell();
	} else {
		error T("You are not on a sell or store npc interaction.\n");
	}
}

##
# 'cm' for Change Material (Genetic)
# 'analysis' for Four Spirit Analysis (Sorcerer) [Untested yet]
# @author [Cydh]
##
sub cmdExchangeItem {
	if (!$net || $net->getState() != Network::IN_GAME) {
		error TF("You must be logged in the game to use this command '%s'\n", shift);
		return;
	}

	my ($switch, $args) = @_;
	my $type;
	my $typename;

	if ($switch eq "cm") {
		if ($skillExchangeItem != 1) { # Change Material (2494)
			error T("This command only available after using 'Change Material' skill!\n");
			return;
		}
		$typename = "Change Material";
	} elsif ($switch eq "analysis") {
		if ($skillExchangeItem != 2 && $skillExchangeItem != 3) { # Four Spirit Analysis (2462)
			error T("This command only available after using 'Four Spirit Analysis' skill!\n");
			return;
		}
		$typename = "Four Spirit Analysis";
	} else {
		error T("Invalid usage!\n");
		return;
	}

	if ($args eq "cancel" || $args eq "end" || $args eq "no") {
		my @items = ();
		message TF("Item Exchange %s is canceled.\n", $typename), "info";
		undef $skillExchangeItem;
		$messageSender->sendItemListWindowSelected(0, $type, 0, \@items); # Cancel: 0
		return;
	}
	$type = $skillExchangeItem-1;

	my ($item1, $amt1) = $args =~ /^(\d+) (\d+)/;

	if ($item1 >= 0 and $amt1 > 0) {
		my @list = split(/,/, $args);
		my @items = ();

		@list = grep(!/^$/, @list); # Remove empty entries
		foreach (@list) {
			my ($invIndex, $amt) = $_ =~ /^(\d+) (\d+)/;
			my $item = $char->inventory->get($invIndex);
			if ($item) {
				if ($item->{amount} < $amt) {
					warning TF("Invalid amount! Only have %dx %s (%d).\n", $item->{amount}, $item->{name}, $invIndex);
				} elsif ($item->{equipped} != 0) {
					warning TF("Equipped item was selected %s (%d)!\n", $item->{name}, $invIndex);
				} else {
					#message TF("Selected: %dx %s\n", $amt, $item->{name});
					push(@items,{itemIndex => $item->{index}, amount => $amt, itemName => $item->{name}});
				}
			} else {
				warning TF("Item in index '%d' is not exists.\n", $invIndex);
			}
		}
		if (@items > 0) {
			my $num = scalar @items;
			message TF("Number of selected items for %s: %d\n", $typename, $num), "info";
			message T("======== Exchange Item List ========\n");
			map {message "$_->{itemName} $_->{amount}x\n"} @items;
			message "==============================\n";
			undef $skillExchangeItem;
			$messageSender->sendItemListWindowSelected($num, $type, 1, \@items); # Process: 1
			return;
		} else {
			error T("No item was selected.\n");
		}
	}

	error TF("Syntax Error in function '%s'. Usages:\n".
			"Single Item: %s <item #> <amount>\n".
			"Combination: %s <item #> <amount>,<item #> <amount>,<item #> <amount>\n", $switch, $switch, $switch);
}

##
# refineui select [item_index]
# refineui refine [item_index] [material_id] [catalyst_toggle]
# @author [Cydh]
##
sub cmdRefineUI {
	if (!$net || $net->getState() != Network::IN_GAME) {
		error TF("You must be logged in the game to use this command '%s'\n", shift);
		return;
	}
	my ($cmd, $args_string) = @_;
	if (!defined $refineUI) {
		error T("Cannot use RefineUI yet.\n");
		return;
	}
	my @args = parseArgs($args_string, 4);

	# refineui close
	# End Refine UI state
	if ($args[0] eq "cancel" || $args[0] eq "end" || $args[0] eq "no") {
		message T("Closing Refine UI.\n"), "info";
		undef $refineUI;
		$messageSender->sendRefineUIClose();
		return;

	# refineui select [item_index]
	# Do refine
	} elsif ($args[0] eq "select") {
		#my ($invIndex) = $args =~ /^(\d+)/;
		my $invIndex = $args[1];

		# Check item
		my $item = $char->inventory->get($invIndex);
		if (!defined $item) {
			warning TF("Item in index '%d' is not exists.\n", $invIndex);
			return;
		} elsif ($item->{equipped} != 0) {
			warning TF("Cannot select equipped %s (%d) item!\n", $item->{name}, $invIndex);
			return;
		}
		$refineUI->{invIndex} = $invIndex;
		message TF("Request info for selected item to refine: %s (%d)\n", $item->{name}, $invIndex);
		$messageSender->sendRefineUISelect( $item->{ID});
		return;

	# refineui refine [item_index] [material_id] [catalyst_toggle]
	# Do refine
	} elsif ($args[0] eq "refine") {
		#my ($invIndex, $matInvIndex, $catalyst) = $args =~ /^(\d+) (\d+) (\d+|yes|no)/;
		my $invIndex = $args[1];
		my $matNameID = $args[2];
		my $catalyst = $args[3];

		# Check item
		my $item = $char->inventory->get($invIndex);
		if (!defined $item) {
			warning TF("Item in index '%d' is not exists.\n", $invIndex);
			return;
		} elsif ($item->{equipped} != 0) {
			warning TF("Cannot select equipped %s (%d) item!\n", $item->{name}, $invIndex);
			return;
		}

		# Check material
		my $material = $char->inventory->getByNameID($matNameID);
		if (!defined $material) {
			warning TF("You don't have enough '%s' (%d) as refine material.\n", itemNameSimple($matNameID), $matNameID);
			return;
		}
		# Check if the selected item is valid material
		my $valid = 0;
		foreach my $mat (@{$refineUI->{materials}}) {
			if ($mat->{nameid} == $matNameID) {
				$valid = 1;
			}
		}
		if ($valid != 1) {
			warning TF("'%s' (%d) is not valid refine material for '%s'.\n", itemNameSimple($matNameID), $matNameID, $item->{name});
			return;
		}

		# Check catalyst toggle
		my $useCatalyst = 0;
		#my $Blacksmith_Blessing = 6635; # 6635,Blacksmith_Blessing,Blacksmith Blessing
		my $blessName = itemNameSimple($Blacksmith_Blessing);
		if ($refineUI->{bless} > 0 && ($catalyst == 1 || $catalyst eq "yes")) {
			my $catalystItem = $char->inventory->getByNameID($Blacksmith_Blessing);
			if (!$catalystItem || $catalystItem->{amount} < $refineUI->{bless}) {
				warning TF("You don't have %s for RefineUI. Needed: %d!\n", $blessName, $refineUI->{bless});
				return;
			}
			$useCatalyst = 1;
		}

		my $matStr = $material->{name};
		if ($useCatalyst) {
			$matStr .= " and ".$refineUI->{bless}."x ".$blessName;
		}
		message TF("Refining item: %s with material %s.\n", $item->{name}, $matStr);
		$messageSender->sendRefineUIRefine($item->{ID}, $matNameID, $useCatalyst);
		return;
	} else {
		error T("Invalid usage!\n");
		return;
	}
}

1;
