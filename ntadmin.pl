#! c:\perl\bin\perl.exe

use strict;
use Win32::Lanman;
use Win32::Registry;

system("cls");
my($count)=0;
my(@MainMenu)=("Exit","Services","Users","Groups","Shares","Server info","Specify remote host");
my(@ServiceMenu)=("Previous menu", "Start service", "Stop service", "Pause service", "Continue service","Change service startup","Change service display name");
my(@UserMenu)=("Previous menu","User info","Add User","Delete User","Change Users Password","Add user to group","Show local groups user is a member of","Show global groups user is a member of");
my(@GroupMenu)=("Previous menu", "Group info","Show Users in Group","Add group","Delete group");
my(@ServerMenu)=("Previous menu","Disk info","Server info","Logged on users","Time settings");
my(@ShareMenu)=("Previous menu","Share info");
my(@ServiceStartupMenu)=("Automatic","Manual","Disabled");
my(@RemoteMenu)=("Previous menu","Set remote host","Set username and password","Reset remote host to local system","Connect to remote host");
my($MenuInput,@services,%services,$user,$pass,$input,%hash,$rhost);
my($server)=$ENV{COMPUTERNAME};
while (1) {
print"       ‹‹‹‹‹   ‹‹‹‹‹‹‹‹‹‹‹‹‹   ‹‹‹‹‹‹‹‹‹   ‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹\n";
print"       €   ﬂﬂﬂﬂ€   ‹   ‹   €   €       €   €   €   ‹   ‹   €   €   ﬂﬂﬂﬂ€\n";
print"       €   ‹   €   €   €   €   €   €   €   €   €   €   €   €   €   €   €\n";
print"       €   €   €   €   €   €   €   €   €‹‹‹€   €   €   €   €ﬂﬂﬂ€   €   €\n";
print"       €   €   €ﬂﬂﬂ€   €ﬂﬂﬂﬂ   €   €   €   ‹   €   €   €   €   €   €   €\n";
print"       €   €   €   €   €       €   ‹   €   €   €   €   €   €   €   €   €\n";
print"       €   €   €   €   €       €   €   €   €   €   €   €   €   €   €   €\n";
print"       €   €   €   €   €       €   €   €   €   €   €   €   €   €   €   €\n";
print"       €   €   €   €   €       €   €   €   €   €   €   €   €   €   €   €\n";
print"       €   €   €   €   €       €   €   €   €   €   €   €   €   €   €   €\n";
print"       €   €   €   €   €       €   €   €   ﬂ   €   €   €   €   €   €   €\n";
print"       ﬂﬂﬂﬂﬂﬂﬂﬂﬂ   ﬂﬂﬂﬂﬂ       ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ\n\n";

	ListMenu(@MainMenu);
	$MenuInput=<STDIN>;
	if ($MenuInput==0) {
		last;
	}
	if ($MenuInput==1) {
		system("cls");
		&ServiceMenu;
	}
	if ($MenuInput==2) {
		system("cls");
		&UserMenu;
	}
	if ($MenuInput==3) {
		system("cls");
		&GroupMenu;
	}
	if ($MenuInput==4) {
		system("cls");
		&ShareMenu;
	}
	if ($MenuInput==5) {
		system("cls");
		&ServerMenu;
	}
	if ($MenuInput==6) {
		system("cls");
		while (1) {
			print "Current remote host: $server\n";
			print "Current username and password\: $user $pass\n\n";
			ListMenu(@RemoteMenu);
			$input=<STDIN>;
			if ($input==0) {
				system("cls");
				last;
			}
			#------------------------
			# Set remote host
			#------------------------
			if ($input==1) {
				Win32::Lanman::NetUseDel("\\\\$server\\ipc\$",&USE_FORCE);
				print "\nEnter new remote host: ";
				$rhost=<STDIN>;
				chop($rhost);
				$server=$rhost;
				print "\nRemote host successfully changed to $server\n";
				&pause;
			}
			#------------------------
			# Set user pass
			#------------------------
			if ($input==2) {
				print "\nEnter username: ";
				$user=<STDIN>;
				chop($user);
				print "\nEnter password: ";
				$pass=<STDIN>;
				chop($pass);
				print "\nUser name and password successfully set to $user\:$pass\n";
				&pause;
				
			}
			#------------------------
			# reset to local computer
			#------------------------
			if ($input==3) {
				Win32::Lanman::NetUseDel("\\\\$server\\ipc\$",&USE_FORCE);
				$server=$ENV{COMPUTERNAME};
				print "\nSuccessfully reset to local computer\n";
				&pause;
			}
			#------------------------
			# Connect to remote host
			#------------------------
			if ($input==4) {
				%hash = (remote => "\\\\$server\\ipc\$",
						asg_type => &USE_IPC,
						password => $pass,
						username => $user,
						domainname => "");
				if (!(Win32::Lanman::NetUseAdd(\%hash))) {
					print "\nerror: " . error(Win32::Lanman::GetLastError()) . "\n";
				} else {
					print "\nSuccessfully connected to remote host $server with $user $pass\n";
					&pause;
				}
			}		
		}
	}
}
Win32::Lanman::NetUseDel("\\\\$server\\ipc\$",&USE_FORCE);
die "\nExiting NT ADMIN.\n";
###################################
# Subs
##################################

#--------------------------
# List the items in each menu array
#--------------------------
sub ListMenu {
	my(@ListMenu)=@_;
	my($ListCount)=0;
	while ($ListCount < @ListMenu ) {
		print ("$ListCount - @ListMenu[$ListCount]\n");
		$ListCount++;
	}
	print "\n";
}
#--------------------------
#  Services Menu
#--------------------------
sub ServiceMenu {
	my(%state,$service,%config,$key,%startup,%display,$input,$startinput,%hash,$displayinput,$serviceinput);
	my($servicecount)=1;
	my(%status) = (	1 => 'Stopped',		2 => 'Start Pending',
			3 => 'Stop Pending',	4 => 'Running',
			5 => 'Continue Pending',6 => 'Pause Pending',
			7 => 'Paused');
	
	my(%start) = (2 => 'AUTOMATIC', 3 => 'MANUAL', 4 => 'DISABLED');

	if(!Win32::Lanman::EnumServicesStatus("\\\\$server", "", &SERVICE_WIN32, &SERVICE_STATE_ALL, \@services)) {
		print "\n\nCannot read services information on $server\n\n";
		return;
	}
	#----------------------------------------
	# associative array of service => startup
	#----------------------------------------
	foreach $service (@services) {
		if(!Win32::Lanman::QueryServiceConfig("\\\\$server", '', "${$service}{name}", \%config)) {
			print "Can't query config of $service on $server " . Win32::Lanman::GetLastError() . "\n";
		}
		foreach (sort keys %config) {
			if ($_ eq 'start') {
				$startup{${$service}{'name'}} = $config{$_};
			}
		}
	}
	#----------------------------------------
	# associative array of service => display
	#----------------------------------------
	foreach $service (@services) {
		if(!Win32::Lanman::QueryServiceConfig("\\\\$server", '', "${$service}{name}", \%config)) {
			print "\nerror: " . error(Win32::Lanman::GetLastError()) . "\n";
		}
		foreach (sort keys %config) {
			if ($_ eq 'display') {
				$display{${$service}{'name'}} = $config{$_};
			}
		}
	}
	#---------------------------------------
	# associative array of service => status
	#---------------------------------------
	foreach (@services) {
		$state{${$_}{'name'}} = ${$_}{'state'};
	}
	#----------------------------------------
	# print services and their status/startup
	#----------------------------------------
	foreach (@services) {
		print "$servicecount-${$_}{name} - $display{${$_}{name}} \($status{$state{${$_}{name}}} $start{$startup{${$_}{name}}}\)\n";
		$services{$servicecount}=${$_}{name};
		$servicecount++;
	}
	#----------------------------------------
	# Services Menu
	#----------------------------------------
	while (1) {
		print "\n";
		ListMenu(@ServiceMenu);
		$input=<STDIN>;
		if ($input==0) {
			system("cls");
			last;
		}
		#--------------
		# Start Service
		#--------------
		if ($input==1) {
			print "\nService number to start: ";
			$serviceinput=<STDIN>;
			chop $serviceinput;
			$serviceinput = $services{$serviceinput};
			if(!Win32::Lanman::StartService("\\\\$server", '', "$serviceinput")) {
				print "\nerror: " . error(Win32::Lanman::GetLastError()) . "\n";
				&pause;
				$servicecount=1;
				foreach (@services) {
					print "$servicecount-${$_}{name} - $display{${$_}{name}} \($status{$state{${$_}{name}}} $start{$startup{${$_}{name}}}\)\n";
					$services{$servicecount}=${$_}{name};
					$servicecount++;
				}
			} else {
				print "\nService $serviceinput \($display{$serviceinput}\) was started successfully\n";
				&pause;
				$servicecount=1;
				foreach (@services) {
					print "$servicecount-${$_}{name} - $display{${$_}{name}} \($status{$state{${$_}{name}}} $start{$startup{${$_}{name}}}\)\n";
					$services{$servicecount}=${$_}{name};
					$servicecount++;
				}
			}
		}
		#--------------
		# Stop Service
		#--------------
		if ($input==2) {
			print "\nService number to stop: ";
			$serviceinput=<STDIN>;
			chop $serviceinput;
			$serviceinput = $services{$serviceinput};
			if(!Win32::Lanman::StopService("\\\\$server", '', "$serviceinput")) {
				print "\nerror: " . error(Win32::Lanman::GetLastError()) . "\n";
				&pause;
				$servicecount=1;
				foreach (@services) {
					print "$servicecount-${$_}{name} - $display{${$_}{name}} \($status{$state{${$_}{name}}} $start{$startup{${$_}{name}}}\)\n";
					$services{$servicecount}=${$_}{name};
					$servicecount++;
				}
			} else {
				print "\nService $serviceinput \($display{$serviceinput}\) was stopped successfully\n";
				&pause;
				$servicecount=1;
				foreach (@services) {
					print "$servicecount-${$_}{name} - $display{${$_}{name}} \($status{$state{${$_}{name}}} $start{$startup{${$_}{name}}}\)\n";
					$services{$servicecount}=${$_}{name};
					$servicecount++;
				}
			}
		}
		#--------------
		# Pause Service
		#--------------
		if ($input==3) {
			print "\nService number to pause: ";
			$serviceinput=<STDIN>;
			chop $serviceinput;
			$serviceinput = $services{$serviceinput};
			if(!Win32::Lanman::PauseService("\\\\$server", '', "$serviceinput")) {
				print "\nerror: " . error(Win32::Lanman::GetLastError()) . "\n";
				&pause;
				$servicecount=1;
				foreach (@services) {
					print "$servicecount-${$_}{name} - $display{${$_}{name}} \($status{$state{${$_}{name}}} $start{$startup{${$_}{name}}}\)\n";
					$services{$servicecount}=${$_}{name};
					$servicecount++;
				}
			} else {
				print "\nService $serviceinput \($display{$serviceinput}\) was paused successfully\n";
				&pause;
				$servicecount=1;
				foreach (@services) {
					print "$servicecount-${$_}{name} - $display{${$_}{name}} \($status{$state{${$_}{name}}} $start{$startup{${$_}{name}}}\)\n";
					$services{$servicecount}=${$_}{name};
					$servicecount++;
				}
			}
		}
		#-----------------
		# Continue Service
		#-----------------
		if ($input==4) {
			print "\nService number to continue: ";
			$serviceinput=<STDIN>;
			chop $serviceinput;
			$serviceinput = $services{$serviceinput};
			if(!Win32::Lanman::ContinueService("\\\\$server", '', "$serviceinput")) {
				print "\nerror: " . error(Win32::Lanman::GetLastError()) . "\n";
				&pause;
				$servicecount=1;
				foreach (@services) {
					print "$servicecount-${$_}{name} - $display{${$_}{name}} \($status{$state{${$_}{name}}} $start{$startup{${$_}{name}}}\)\n";
					$services{$servicecount}=${$_}{name};
					$servicecount++;
				}
			} else {
				print "\nService $serviceinput \($display{$serviceinput}\) was continued successfully\n";
				&pause;
				$servicecount=1;
				foreach (@services) {
					print "$servicecount-${$_}{name} - $display{${$_}{name}} \($status{$state{${$_}{name}}} $start{$startup{${$_}{name}}}\)\n";
					$services{$servicecount}=${$_}{name};
					$servicecount++;
				}
			}
		}
		#---------------
		# Change Startup
		#---------------
		if ($input==5) {
			print "\nService number to change: ";
			$serviceinput=<STDIN>;
			chop $serviceinput;
			$serviceinput = $services{$serviceinput};
			print "\n";
			ListMenu(@ServiceStartupMenu);
			$startinput=<STDIN>;
			while (1) {
				if ($startinput==0) {
					if (!Win32::Lanman::ChangeServiceConfig("\\\\$server", '' ,$serviceinput, {start => '2'})) {
						print "\nerror: " . error(Win32::Lanman::GetLastError()) . "\n";
						&pause;
						$servicecount=1;
						foreach (@services) {
							print "$servicecount-${$_}{name} - $display{${$_}{name}} \($status{$state{${$_}{name}}} $start{$startup{${$_}{name}}}\)\n";
							$services{$servicecount}=${$_}{name};
							$servicecount++;
						}
					} else {
						print "\nService $serviceinput \($display{$serviceinput}\) was successfully set to Automatic\n";
						&pause;
						$servicecount=1;
						foreach (@services) {
							print "$servicecount-${$_}{name} - $display{${$_}{name}} \($status{$state{${$_}{name}}} $start{$startup{${$_}{name}}}\)\n";
							$services{$servicecount}=${$_}{name};
							$servicecount++;
						}
					}
				}
				if ($startinput==1) {
					if (!Win32::Lanman::ChangeServiceConfig("\\\\$server", '' ,$serviceinput, {start => '3'})) {
						print "\nerror: " . error(Win32::Lanman::GetLastError()) . "\n";
						&pause;
						$servicecount=1;
						foreach (@services) {
							print "$servicecount-${$_}{name} - $display{${$_}{name}} \($status{$state{${$_}{name}}} $start{$startup{${$_}{name}}}\)\n";
							$services{$servicecount}=${$_}{name};
							$servicecount++;
						}
					} else {
						print "\nService $serviceinput \($display{$serviceinput}\) was successfully set to Manual\n";
						&pause;
						$servicecount=1;
						foreach (@services) {
							print "$servicecount-${$_}{name} - $display{${$_}{name}} \($status{$state{${$_}{name}}} $start{$startup{${$_}{name}}}\)\n";
							$services{$servicecount}=${$_}{name};
							$servicecount++;
						}
					}
				}
				 if ($startinput==2) {
					if (!Win32::Lanman::ChangeServiceConfig("\\\\$server", '' ,$serviceinput, {start => '4'})) {
						print "\nerror: " . error(Win32::Lanman::GetLastError()) . "\n";
						&pause;
						$servicecount=1;
						foreach (@services) {
							print "$servicecount-${$_}{name} - $display{${$_}{name}} \($status{$state{${$_}{name}}} $start{$startup{${$_}{name}}}\)\n";
							$services{$servicecount}=${$_}{name};
							$servicecount++;
						}
					} else {
						print "\nService $serviceinput \($display{$serviceinput}\) was successfully set to Disabled\n";
						&pause;
						$servicecount=1;
						foreach (@services) {
							print "$servicecount-${$_}{name} - $display{${$_}{name}} \($status{$state{${$_}{name}}} $start{$startup{${$_}{name}}}\)\n";
							$services{$servicecount}=${$_}{name};
							$servicecount++;
						}
					}
				}
				print "\nInvalid selection.\n";
				&pause;
				&ServiceMenu;
			}		
		}
		#--------------------
		# Change display name
		#--------------------
		if ($input==6) {
			print "\nService number to continue: ";
			$serviceinput=<STDIN>;
			chop $serviceinput;
			print "\nNew display name: ";
			$displayinput=<STDIN>;
			chop $displayinput;
			$serviceinput = $services{$serviceinput};
			if (!Win32::Lanman::ChangeServiceConfig("\\\\$server", '' ,$serviceinput, {display => $displayinput})) {
				print "\nerror: " . error(Win32::Lanman::GetLastError()) . "\n";
				&pause;
				$servicecount=1;
				foreach (@services) {
					print "$servicecount-${$_}{name} - $display{${$_}{name}} \($status{$state{${$_}{name}}} $start{$startup{${$_}{name}}}\)\n";
					$services{$servicecount}=${$_}{name};
					$servicecount++;
				}
			} else {
				print "\nService $serviceinput \($display{$serviceinput}\) display name was successfully changed to $displayinput\n";
				&pause;
				$servicecount=1;
				foreach (@services) {
					print "$servicecount-${$_}{name} - $display{${$_}{name}} \($status{$state{${$_}{name}}} $start{$startup{${$_}{name}}}\)\n";
					$services{$servicecount}=${$_}{name};
					$servicecount++;
				}
			}
		}
	}
}
#--------------------------
#  Groups Menu
#--------------------------
sub GroupMenu {
	my($MenuInput,@groups,$groupinput,%group,%groupinfo,@group);
	my($groupcount)=1;
	while(1) {
		unless(Win32::Lanman::NetLocalGroupEnum("\\\\$server", \@groups)) {
			print "\nerror: " . error(Win32::Lanman::GetLastError()) . "\n";
			&pause;
		}
		foreach (@groups) {
			print "$groupcount-${$_}{'name'}\n";
			$group{$groupcount}=${$_}{name};
			$groupcount++;
		}
		$groupcount=1;
		print "\n";
		ListMenu(@GroupMenu);
		$MenuInput=<STDIN>;
		if ($MenuInput==0) {
			system("cls");
			last;
		}
		#--------------
		# Group info
		#--------------
		if ($MenuInput==1) {
			print "\nEnter group number: ";
			$groupinput=<STDIN>;
			chop ($groupinput);
			if(!Win32::Lanman::NetLocalGroupGetInfo("\\\\$server", "$group{$groupinput}",\%groupinfo)) {
				print "\nerror: " . error(Win32::Lanman::GetLastError()) . "\n";
				&pause;
			} else {
				print "$groupinfo{'name'}\t$groupinfo{'comment'}\n";
				&pause;
			}
		}
		#--------------------
		# Show users in group
		#--------------------
		if ($MenuInput==2) {
			print "\nEnter group number: ";
			$groupinput=<STDIN>;
			chop ($groupinput);
			print "\n";
			if(!Win32::Lanman::NetLocalGroupGetMembers("\\\\$server", "$group{$groupinput}",\@group)) {
				print "\nerror: " . error(Win32::Lanman::GetLastError()) . "\n";
				&pause;
			} else {
				foreach (@group) {
					print "${$_}{'domainandname'}\n";
					print "${$_}{'sid'}\n";
				}
				&pause;
			}
		}
		#--------------
		# Add group
		#--------------
		if ($MenuInput==3) {
			print "\nEnter group to add: ";
			$groupinput=<STDIN>;
			chop ($groupinput);
			if(!Win32::Lanman::NetLocalGroupAdd("\\\\$server", "$groupinput", "")) {
				print "\nerror: " . error(Win32::Lanman::GetLastError()) . "\n";
				&pause;
			} else {
				print "\nGroup $groupinput was successfully added to $server\n";
				&pause;
			}
		}
		#--------------
		# Delete group
		#--------------
		if ($MenuInput==4) {
			print "\nEnter group number to delete: ";
			$groupinput=<STDIN>;
			chop ($groupinput);
			if(!Win32::Lanman::NetLocalGroupDel("\\\\$server", "$group{$groupinput}")) {
				print "\nerror: " . error(Win32::Lanman::GetLastError()) . "\n";
				&pause;
			} else {
				print "\nGroup $group{$groupinput} was successfully deleted from $server\n";
				&pause;
			}
		}
	}
}
#--------------------------
#  Users Menu
#--------------------------
sub UserMenu {
	my($MenuInput,@users,$MenuInput,$userinput,$hours,%info,$oldpassword,$password,@groups,%user,$groupadd);
	my($usercount)=1;
	while(1) {
		if(!Win32::Lanman::NetUserEnum("\\\\$server", &FILTER_NORMAL_ACCOUNT, \@users)) {
			print "\nerror: " . error(Win32::Lanman::GetLastError()) . "\n";
			&pause;
		} else {

			foreach (@users) {
				print "$usercount-${$_}{'name'}\n";
				$user{$usercount}=${$_}{name};
				$usercount++;
			}
		}
		$usercount=1;
		print "\n";
		ListMenu(@UserMenu);
		$MenuInput=<STDIN>;
		if ($MenuInput==0) {
			system("cls");
			last;
		}
		#--------------------------
		#  User info
		#--------------------------
		if ($MenuInput==1) {
			print "\nEnter user number: ";
			$userinput=<STDIN>;
			chop ($userinput);
			if(!Win32::Lanman::NetUserGetInfo("$server", "$user{$userinput}", \%info)) {
				print "\nerror: " . error(Win32::Lanman::GetLastError()) . "\n";
			} else {	
				$hours = unpack("b168", $user{'logon_hours'});
				print "name\t\t=\t$info{'name'}\n";
				print "comment\t\t=\t$info{'comment'}\n";
				print "usr comment\t=\t$info{'usr_comment'}\n";
				print "full name\t=\t$info{'full_name'}\n";
				print "password age\t=\t$info{'password_age'}\n";
				print "priv\t\t=\t$info{'priv'}\n";
				print "home dir\t=\t$info{'home_dir'}\n";
				print "flags\t\t=\t$info{'flags'}\n";
				print "script path\t=\t$info{'script_path'}\n";
				print "auth flags\t=\t$info{'auth_flags'}\n";
				print "parms\t\t=\t$info{'parms'}\n";
				print "workstations\t=\t$info{'workstations'}\n";
				print "last logon\t=\t$info{'last_logon'}\n";
				print "last logoff\t=\t$info{'last_logoff'}\n";
				print "acct expires\t=\t$info{'acct_expires'}\n";
				print "max storage\t=\t$info{'max_storage'}\n";
				print "units per week\t=\t$info{'units_per_week'}\n";
				print "hours\t\t=\t$hours\n";
				print "bad pw count\t=\t$info{'bad_pw_count'}\n";
				print "num logons\t=\t$info{'num_logons'}\n";
				print "logon server\t=\t$info{'logon_server'}\n";
				print "country code\t=\t$info{'country_code'}\n";
				print "code page\t=\t$info{'code_page'}\n";
				print "user id\t\t=\t$info{'user_id'}\n";
				print "primary group id=\t$info{'primary_group_id'}\n";
				print "profile\t\t=\t$info{'profile'}\n";
				print "home dir drive\t=\t$info{'home_dir_drive'}\n";
				print "info\t\t=\t$info{'password_expired'}\n";
				&pause;
			}
		}
		#--------------------------
		#  Add user
		#--------------------------
		if ($MenuInput==2) {
			print "\nEnter user to add: ";
			$userinput=<STDIN>;
			print "\nEnter password for user: ";
			$password=<STDIN>;
			chop ($userinput);
			chop ($password);
			if(!Win32::Lanman::NetUserAdd("\\\\$server", {'name' => $userinput,'password' => $password})) {
				print "\nerror: " . error(Win32::Lanman::GetLastError()) . "\n";
				&pause;
			} else {
				print "\nUser $userinput was successfully added to $server with password $password\n";
				&pause;
			}
		}
		#--------------------------
		#  Delete user
		#--------------------------
		if ($MenuInput==3) {
			print "\nEnter user number to delete: ";
			$userinput=<STDIN>;
			chop ($userinput);
			if(!Win32::Lanman::NetUserDel("\\\\$server", $user{$userinput})) {
				print "\nerror: " . error(Win32::Lanman::GetLastError()) . "\n";
				&pause;
			} else {
				print "\nUser $user{$userinput} was successfully deleted from $server\n";
				&pause;
			}
		}
		#--------------------------
		#  Change users password
		#--------------------------
		if ($MenuInput==4) {
			print "\nEnter user number to change password: ";
			$userinput=<STDIN>;
			print "\nEnter old password: ";
			$oldpassword=<STDIN>;
			print "\nEnter new password: ";
			$password=<STDIN>;
			chop ($userinput);
			chop ($oldpassword);
			chop ($password);
			if(!Win32::Lanman::NetUserChangePassword("\\\\$server", $user{$userinput},$oldpassword,$password)) {
				print "\nerror: " . error(Win32::Lanman::GetLastError()) . "\n";
				&pause;
			} else {
				print "\nPassword successfully set for $user{$userinput} on $server\n";
				&pause;
			}
		}
		#--------------------------
		#  Add user to group
		#--------------------------
		if ($MenuInput==5) {
			print "\nEnter user number: ";
			$userinput=<STDIN>;
			chop ($userinput);
			print "\nEnter group to add user to: ";
			$groupadd=<STDIN>;
			chop ($groupadd);
			@groups[0]=$user{$userinput};
			if(!Win32::Lanman::NetLocalGroupAddMembers("\\\\$server", $groupadd, \@groups)) {
				print "\nerror: " . error(Win32::Lanman::GetLastError()) . "\n";
				&pause;
			} else {
				print "\nUser $user{$userinput} was successfully added to $groupadd on $server\n";
				&pause;
			}
		}
		#--------------------------
		#  Show local groups user is a member of
		#--------------------------
		if ($MenuInput==6) {
			print "\nEnter user number: ";
			$userinput=<STDIN>;
			chop ($userinput);
			print "\n";
			if(!Win32::Lanman::NetUserGetLocalGroups("\\\\$server", $user{$userinput}, &LG_INCLUDE_INDIRECT,\@groups)) {
				print "\nerror: " . error(Win32::Lanman::GetLastError()) . "\n";
				&pause;
			} else {
				foreach (@groups) {
					print "${$_}{'name'}\n";
				}
				&pause;
			}
		}
	#--------------------------
	#  Show global groups user is a member of
	#--------------------------
		if ($MenuInput==7) {
			print "\nEnter user number: ";
			$userinput=<STDIN>;
			chop ($userinput);
			print "\n";
			if(!Win32::Lanman::NetUserGetGroups("\\\\$server", $user{$userinput},\@groups)) {
				print "\nerror: " . error(Win32::Lanman::GetLastError()) . "\n";
				&pause;
			} else {
				foreach (@groups) {
					print "${$_}{'name'}\n";
				}
				&pause;
			}
		}
	}
}
#--------------------------
#  Share Menu
#--------------------------
sub ShareMenu {
	my(@shares,%share,$MenuInput,$shareinput,%info);
	my($sharecount)=1;
	while (1) {
		if(!Win32::Lanman::NetShareEnum("\\\\$server", \@shares)) {
			print "\nerror: " . error(Win32::Lanman::GetLastError()) . "\n";
		} else {
			foreach (@shares) {
				print "$sharecount-${$_}{'netname'}\n";
				$share{$sharecount}=${$_}{netname};
				$sharecount++;
			}
		}
		$sharecount=1;
		print "\n";
		ListMenu(@ShareMenu);
		$MenuInput=<STDIN>;
		if ($MenuInput==0) {
			system("cls");
			last;
		}
		#-------------
		#  Share Info
		#-------------
		if ($MenuInput==1) {
			print "\nEnter share number to view: ";
			$shareinput=<STDIN>;			
			chop ($shareinput);
			system("cls");
			if(!Win32::Lanman::NetShareGetInfo("\\\\$server", "$share{$shareinput}", \%info)) {
				print "\nerror: " . error(Win32::Lanman::GetLastError()) . "\n";
				&pause;
			} else {
				print "netname\t\t=\t$info{'netname'}\n";
				print "type\t\t=\t$info{'type'}\n";
				print "remark\t\t=\t$info{'remark'}\n";
				print "permissions\t=\t$info{'permissions'}\n";
				print "max uses\t=\t$info{'max_uses'}\n";
				print "current uses\t=\t$info{'current_uses'}\n";
				print "path\t\t=\t$info{'path'}\n\n";
				&pause;
			}
		}
	}
}
#--------------------------
#  Server Menu
#--------------------------
sub ServerMenu {
	my($MenuInput,$serverinput,@disks,$disk,%info,@keys,@info,$key);

	while (1) {
		ListMenu(@ServerMenu);
		$MenuInput=<STDIN>;
		if ($MenuInput==0) {
			system("cls");
			last;
		}
		#--------------
		#  Disk info
		#--------------
		if ($MenuInput==1) {
			system("cls");
			if(!Win32::Lanman::NetServerDiskEnum("\\\\$server", \@disks)) {
				print "\nerror: " . error(Win32::Lanman::GetLastError()) . "\n";
				&pause;
			} else {
				print "$server disk info.\n\n";
				foreach (@disks) {
					print "$_\n";
				}
			}
			&pause;
		}
		#-------------
		#  Server info
		#-------------
		if ($MenuInput==2) {
			system("cls");
			if(!Win32::Lanman::NetServerGetInfo("\\\\$server", \%info, 1)) {
				print "\nerror: " . error(Win32::Lanman::GetLastError()) . "\n";
				&pause;
			} else {
				@keys = keys %info;
				foreach (@keys) {
					print "$_=$info{$_}\n";
				}
			}
			&pause;
		}
		#-------------
		#  Logged on users
		#-------------
		if ($MenuInput==3) {
			system("cls");
			if(!Win32::Lanman::NetWkstaUserEnum("\\\\$server", \@info)) {
				print "\nerror: " . error(Win32::Lanman::GetLastError()) . "\n";
				&pause;
			} else {
				foreach (@info) {
					@keys = keys %$_;
					foreach $key (@keys) {
						print "$key=${$_}{$key}\n";
					}
				}
			}
			&pause;
		}
		#-------------
		#  Time settings
		#-------------
		if ($MenuInput==4) {
			system("cls");
			if(!Win32::Lanman::NetRemoteTOD("\\\\192.168.0.2", \%info)) {
				print "\nerror: " . error(Win32::Lanman::GetLastError()) . "\n";
				&pause;
			} else {
				@keys = keys %info;
				foreach $key(@keys) {
					print "$key=$info{$key}\n";
				}
			}
			&pause;
		}
	}
}
#--------------
# remote host
#--------------
#sub Rhost {
#	my($input,$rhost,$user,$pass);
#	while (1) {
#		print "Current remote host: $server\n\n";
#		ListMenu(@RemoteMenu);
#		$input=<STDIN>;
#		if ($input==0) {
#			system("cls");
#			last;
#		}
#		if ($input==1) {
#			print "\nEnter new remote host: ";
#			$rhost=<STDIN>;
#			chop($rhost);
#			$server=$rhost;
#			print "\nRemote host successfully changed to $server\n";
#			&pause;
#		}
#		if ($input==2) {
#			print "\nEnter username: ";
#			$user=<STDIN>;
#			print "\nEnter password: ";
#			$pass=<STDIN>;
#			
#		}
#			
#		if ($input==3) {
#			$server=$ENV{COMPUTERNAME};
#			print "\nSuccessfully reset to local computer\n";
#			&pause;
#		}
#			
#	}
#	
#}
#------------
# pause
#------------
sub pause {
	my ($pause);
	print "\npress enter to continue...";
	$pause=<STDIN>;
	system("cls");
}
#------------
# error codes
#------------
sub error {
	my ($msg) = @_;
	my(%error) = (
		0 => 'The operation was successfully completed.',
		1 => 'The function is incorrect.',
		2 => 'The system cannot find the file specified.',
		3 => 'The system cannot find the specified path.',
		4 => 'The system cannot open the file.',
		5 => 'Access is denied.',
		6 => 'The internal file identifier is incorrect.',
		7 => 'The storage control blocks were destroyed.',
		8 => 'Not enough storage is available to process this command.',
		9 => 'The storage control block address is invalid.',
		10 => 'The environment is incorrect.',
		11 => 'An attempt was made to load a program with an incorrect format.',
		12 => 'The access code is invalid.',
		13 => 'The data is invalid.',
		14 => 'Not enough storage is available to complete this operation.',
		15 => 'The system cannot find the specified drive.',
		16 => 'The directory cannot be removed.',
		17 => 'The system cannot move the file to a different disk drive.',
		18 => 'There are no more files.',
		19 => 'The media is write protected.',
		20 => 'The system cannot find the specified device.',
		21 => 'The drive is not ready.',
		22 => 'The device does not recognize the command.',
		23 => 'Data error (cyclic redundancy check).',
		24 => 'The program issued a command but the command length is incorrect.',
		25 => 'The drive cannot locate a specific area or track on the disk.',
		26 => 'The specified disk cannot be accessed.',
		27 => 'The drive cannot find the requested sector.',
		28 => 'The printer is out of paper.',
		29 => 'The system cannot write to the specified device.',
		30 => 'The system cannot read from the specified device.',
		31 => 'A device attached to the system is not functioning.',
		32 => 'The process cannot access the file because it is being used by another process.',
		33 => 'The process cannot access the file because another process has locked a portion of the file.',
		34 => 'The wrong disk is in the drive. Insert %2 (Volume Serial Number: %3) into drive %1.',
		36 => 'Too many files opened for sharing.',
		38 => 'Reached End Of File.',
		39 => 'The disk is full.',
		50 => 'The network request is not supported.',
		51 => 'The remote computer is not available.',
		52 => 'A duplicate name exists on the network.',
		53 => 'The network path was not found.',
		54 => 'The network is busy.',
		55 => 'The specified network resource is no longer available.',
		56 => 'The network BIOS command limit has been reached.',
		57 => 'A network adapter hardware error occurred.',
		58 => 'The specified server cannot perform the requested operation.',
		59 => 'An unexpected network error occurred.',
		60 => 'The remote adapter is not compatible.',
		61 => 'The printer queue is full.',
		62 => 'Space to store the file waiting to be printed is not available on the server.',
		63 => 'File waiting to be printed was deleted.',
		64 => 'The specified network name is no longer available.',
		65 => 'Network access is denied.',
		66 => 'The network resource type is incorrect.',
		67 => 'The network name cannot be found.',
		68 => 'The name limit for the local computer network adapter card exceeded.',
		69 => 'The network BIOS session limit exceeded.',
		70 => 'The remote server is paused or is in the process of being started.',
		71 => 'The network request was not accepted.',
		72 => 'The specified printer or disk device has been paused.',
		80 => 'The file exists.',
		82 => 'The directory or file cannot be created.',
		83 => 'Fail on INT 24.',
		84 => 'Storage to process this request is not available.',
		85 => 'The local device name is already in use.',
		86 => 'The specified network password is incorrect.',
		87 => 'The parameter is incorrect.',
		88 => 'A write fault occurred on the network.',
		89 => 'The system cannot start another process at this time.',
		100 => 'Cannot create another system semaphore.',
		101 => 'The exclusive semaphore is owned by another process.',
		102 => 'The semaphore is set and cannot be closed.',
		103 => 'The semaphore cannot be set again.',
		104 => 'Cannot request exclusive semaphores at interrupt time.',
		105 => 'The previous ownership of this semaphore has ended.',
		106 => 'Insert the disk for drive 1.',
		107 => 'Program stopped because alternate disk was not inserted.',
		108 => 'The disk is in use or locked by another process.',
		109 => 'The pipe was ended.',
		110 => 'The system cannot open the specified device or file.',
		111 => 'The file name is too long.',
		112 => 'There is not enough space on the disk.',
		113 => 'No more internal file identifiers available.',
		114 => 'The target internal file identifier is incorrect.',
		117 => 'The IOCTL call made by the application program is incorrect.',
		118 => 'The verify-on-write switch parameter value is incorrect.',
		119 => 'The system does not support the requested command.',
		120 => 'The Application Program Interface (API) entered will only work in Windows/NT mode.',
		121 => 'The semaphore timeout period has expired.',
		122 => 'The data area passed to a system call is too small.',
		123 => 'The file name, directory name, or volume label is syntactically incorrect.',
		124 => 'The system call level is incorrect.',
		125 => 'The disk has no volume label.',
		126 => 'The specified module cannot be found.',
		127 => 'The specified procedure could not be found.',
		128 => 'There are no child processes to wait for.',
		129 => 'The %1 application cannot be run in Windows mode.',
		130 => 'Attempt to use a file handle to an open disk partition for an operation other than raw disk I/O.',
		131 => 'An attempt was made to move the file pointer before the beginning of the file.',
		132 => 'The file pointer cannot be set on the specified device or file.',
		133 => 'A JOIN or SUBST command cannot be used for a drive that contains previously joined drives.',
		134 => 'An attempt was made to use a JOIN or SUBST command on a drive that is already joined.',
		135 => 'An attempt was made to use a JOIN or SUBST command on a drive already substituted.',
		136 => 'The system attempted to delete the JOIN of a drive not previously joined.',
		137 => 'The system attempted to delete the substitution of a drive not previously substituted.',
		138 => 'The system tried to join a drive to a directory on a joined drive.',
		139 => 'The system attempted to substitute a drive to a directory on a substituted drive.',
		140 => 'The system tried to join a drive to a directory on a substituted drive.',
		141 => 'The system attempted to SUBST a drive to a directory on a joined drive.',
		142 => 'The system cannot perform a JOIN or SUBST at this time.',
		143 => 'The system cannot join or substitute a drive to or for a directory on the same drive.',
		144 => 'The directory is not a subdirectory of the root directory.',
		145 => 'The directory is not empty.',
		146 => 'The path specified is being used in a substitute.',
		147 => 'Not enough resources are available to process this command.',
		148 => 'The specified path cannot be used at this time.',
		149 => 'An attempt was made to join or substitute a drive for which a directory on the drive is the target of a previous substitute.',
		150 => 'System trace information not specified in your CONFIG.SYS file, or tracing is not allowed.',
		151 => 'The number of specified semaphore events is incorrect.',
		152 => 'Too many semaphores are already set.',
		153 => 'The list is not correct.',
		154 => 'The volume label entered exceeds the 11 character limit. The first 11 characters were written to disk. Any characters that exceeded the 11 character limit were automatically deleted.',
		155 => 'Cannot create another thread.',
		156 => 'The recipient process has refused the signal.',
		157 => 'The segment is already discarded and cannot be locked.',
		158 => 'The segment is already unlocked.',
		159 => 'The address for the thread ID is incorrect.',
		160 => 'The argument string passed to DosExecPgm is incorrect.',
		161 => 'The specified path name is invalid.',
		162 => 'A signal is already pending.',
		164 => 'No more threads can be created in the system.',
		167 => 'Attempt to lock a region of a file failed.',
		170 => 'The requested resource is in use.',
		173 => 'A lock request was not outstanding for the supplied cancel region.',
		174 => 'The file system does not support atomic changing of the lock type.',
		180 => 'The system detected a segment number that is incorrect.',
		182 => 'The operating system cannot run %1.',
		183 => 'Attempt to create file that already exists.',
		186 => 'The flag passed is incorrect.',
		187 => 'The specified system semaphore name was not found.',
		188 => 'The operating system cannot run %1.',
		189 => 'The operating system cannot run %1.',
		190 => 'The operating system cannot run %1.',
		191 => '%1 cannot be run in Windows/NT mode.',
		192 => 'The operating system cannot run %1.',
		193 => '%1 is not a valid Windows-based application.',
		194 => 'The operating system cannot run %1.',
		195 => 'The operating system cannot run %1.',
		196 => 'The operating system cannot run this application program.',
		197 => 'The operating system is not presently configured to run this application.',
		198 => 'The operating system cannot run %1.',
		199 => 'The operating system cannot run this application program.',
		200 => 'The code segment cannot be greater than or equal to 64KB.',
		201 => 'The operating system cannot run %1.',
		202 => 'The operating system cannot run %1.',
		203 => 'The system could not find the environment option entered.',
		205 => 'No process in the command subtree has a signal handler.',
		206 => 'The file name or extension is too long.',
		207 => 'The ring 2 stack is in use.',
		208 => 'The global filename characters * or ? are entered incorrectly, or too many global filename characters are specified.',
		209 => 'The signal being posted is incorrect.',
		210 => 'The signal handler cannot be set.',
		212 => 'The segment is locked and cannot be reallocated.',
		214 => 'Too many dynamic link modules are attached to this program or dynamic link module.',
		215 => 'Can\'t nest calls to LoadModule.',
		230 => 'The pipe state is invalid.',
		231 => 'All pipe instances busy.',
		232 => 'Pipe close in progress.',
		233 => 'No process on other end of pipe.',
		234 => 'More data is available.',
		240 => 'The session was canceled.',
		254 => 'The specified EA name is invalid.',
		255 => 'The EAs are inconsistent.',
		259 => 'No more data is available.',
		266 => 'The Copy API cannot be used.',
		267 => 'The directory name is invalid.',
		275 => 'The EAs did not fit in the buffer.',
		276 => 'The EA file on the mounted file system is damaged.',
		277 => 'The EA table in the EA file on the mounted file system is full.',
		278 => 'The specified EA handle is invalid.',
		282 => 'The mounted file system does not support extended attributes.',
		288 => 'Attempt to release mutex not owned by caller.',
		298 => 'Too many posts made to a semaphore.',
		299 => 'Only part of a Read/WriteProcessMemory request was completed.',
		317 => 'The system cannot find message for message number 0x%1 in message file for %2.',
		487 => 'Attempt to access invalid address.',
		534 => 'Arithmetic result exceeded 32-bits.',
		535 => 'There is a process on other end of the pipe.',
		536 => 'Waiting for a process to open the other end of the pipe.',
		994 => 'Access to the EA is denied.',
		995 => 'The I/O operation was aborted due to either thread exit or application request.',
		996 => 'Overlapped IO event not in signaled state.',
		997 => 'Overlapped IO operation in progress.',
		998 => 'Invalid access to memory location.',
		999 => 'Error accessing paging file.',
		1001 => 'Recursion too deep, stack overflowed.',
		1002 => 'Window can\'t handle sent message.',
		1003 => 'Cannot complete function for some reason.',
		1004 => 'The flags are invalid.',
		1005 => 'The volume does not contain a recognized file system. Make sure that all required file system drivers are loaded and the volume is not damaged.',
		1006 => 'The volume for a file was externally altered and the opened file is no longer valid.',
		1007 => 'The requested operation cannot be performed in full-screen mode.',
		1008 => 'An attempt was made to reference a token that does not exist.',
		1009 => 'The configuration registry database is damaged.',
		1010 => 'The configuration registry key is invalid.',
		1011 => 'The configuration registry key cannot be opened.',
		1012 => 'The configuration registry key cannot be read.',
		1013 => 'The configuration registry key cannot be written.',
		1014 => 'One of the files containing the system\'s registry data had to be recovered by use of a log or alternate copy. The recovery succeeded.',
		1015 => 'The registry is damaged. The structure of one of the files that contains registry data is damaged, or the system\'s in memory image of the file is damaged, or the file could not be recoveredbecause its alternate copy or log was absent or damaged.',
		1016 => 'The registry initiated an I/O operation that had an unrecoverable failure. The registry could not read in, or write out, or flush, one of the files that contain the system\'s image of the registry.',
		1017 => 'The system attempted to load or restore a file into the registry, and the specified file isnot in the format of a registry file.',
		1018 => 'Illegal operation attempted on a registry key that has been marked for deletion.',
		1019 => 'System could not allocate required space in a registry log.',
		1020 => 'An attempt was made to create a symbolic link in a registry key that already has subkeys or values.',
		1021 => 'An attempt was made to create a stable subkey under a volatile parent key.',
		1022 => 'This indicates that a notify change request is being completed and the information is not being returned in the caller\'s buffer. The caller now needs to enumerate the files to find the changes.',
		1051 => 'A stop control has been sent to a service which other running services are dependent on.',
		1052 => 'The requested control is not valid for this service',
		1053 => 'The service did not respond to the start or control request in a timely fashion.',
		1054 => 'A thread could not be created for the service.',
		1055 => 'The service database is locked.',
		1056 => 'An instance of the service is already running.',
		1057 => 'The account name is invalid or does not exist.',
		1058 => 'The specified service is disabled and cannot be started.',
		1059 => 'Circular service dependency was specified.',
		1060 => 'The specified service does not exist as an installed service.',
		1061 => 'The service cannot accept control messages at this time.',
		1062 => 'The service has not been started.',
		1063 => 'The service process could not connect to the service controller.',
		1064 => 'An exception occurred in the service when handling the control request.',
		1065 => 'The database specified does not exist.',
		1066 => 'The service has returned a service-specific error code.',
		1067 => 'The process terminated unexpectedly.',
		1068 => 'The dependency service or group failed to start.',
		1069 => 'The service did not start due to a logon failure.',
		1070 => 'After starting, the service hung in a start-pending state.',
		1071 => 'The specified service database lock is invalid.',
		1072 => 'The specified service has been marked for deletion.',
		1073 => 'The specified service already exists.',
		1074 => 'The system is currently running with the last-known-good configuration.',
		1075 => 'The dependency service does not exist or has been marked for deletion.',
		1076 => 'The current boot has already been accepted for use as the last-known-good control set.',
		1077 => 'No attempts to start the service have been made since the last boot.',
		1078 => 'The name is already in use as either a service name or a service display name.',
		1079 => 'The account specified for this service is different from the account specified for other services running in the same process.',
		1100 => 'The physical end of the tape has been reached.',
		1101 => 'A tape access reached a filemark.',
		1102 => 'The beginning of the tape or partition was encountered.',
		1103 => 'A tape access reached a setmark.',
		1104 => 'During a tape access, the end of the data marker was reached.',
		1105 => 'Tape could not be partitioned.',
		1106 => 'When accessing a new tape of a multivolume partition, the current block size is incorrect.',
		1107 => 'Tape partition information could not be found when loading a tape.',
		1108 => 'Attempt to lock the eject media mechanism failed.',
		1109 => 'Unload media failed.',
		1110 => 'Media in drive may have changed.',
		1111 => 'The I/O bus was reset.',
		1112 => 'Tape query failed because of no media in drive.',
		1113 => 'No mapping for the Unicode character exists in the target multi-byte code page.',
		1114 => 'A DLL initialization routine failed.',
		1115 => 'A system shutdown is in progress.',
		1116 => 'An attempt to abort the shutdown of the system failed because no shutdown was in progress.',
		1117 => 'The request could not be performed because of an I/O device error.',
		1118 => 'No serial device was successfully initialized. The serial driver will unload.',
		1119 => 'Unable to open a device that was sharing an interrupt request (IRQ) with other devices. At least one other device that uses that IRQ was already opened.',
		1120 => 'A serial I/O operation was completed by another write to the serial port. (The IOCTL_SERIAL_XOFF_COUNTER reached zero.)',
		1121 => 'A serial I/O operation completed because the time-out period expired. (The IOCTL_SERIAL_XOFF_COUNTER did not reach zero.)',
		1122 => 'No ID address mark was found on the floppy disk.',
		1123 => 'Mismatch between the floppy disk sector ID field and the floppy disk controller track address.',
		1124 => 'The floppy disk controller reported an error that is not recognized by the floppy disk driver.',
		1125 => 'The floppy disk controller returned inconsistent results in its registers.',
		1126 => 'While accessing the hard disk, a recalibrate operation failed, even after retries.',
		1127 => 'While accessing the hard disk, a disk operation failed even after retries.',
		1128 => 'While accessing the hard disk, a disk controller reset was needed, but even that failed.',
		1129 => 'Physical end of tape encountered.',
		1130 => 'Not enough server storage is available to process this command.',
		1131 => 'A potential deadlock condition has been detected.',
		1132 => 'The base address or the file offset specified does not have the proper alignment.',
		1140 => 'An attempt to change the system power state was vetoed by another application or driver.',
		1141 => 'The system BIOS failed an attempt to change the system power state.',
		1142 => 'An attempt was made to create more links on a file than the file system supports.',
		1150 => 'The specified program requires a newer version of Windows.',
		1151 => 'The specified program is not a Windows or MS-DOS program.',
		1152 => 'Cannot start more than one instance of the specified program.',
		1153 => 'The specified program was written for an older version of Windows.',
		1154 => 'One of the library files needed to run this application is damaged.',
		1155 => 'No application is associated with the specified file for this operation.',
		1156 => 'An error occurred in sending the command to the application.',
		1157 => 'One of the library files needed to run this application cannot be found.',
		1200 => 'The specified device name is invalid.',
		1201 => 'The device is not currently connected but is a remembered connection.',
		1202 => 'An attempt was made to remember a device that was previously remembered.',
		1203 => 'No network provider accepted the given network path.',
		1204 => 'The specified network provider name is invalid.',
		1205 => 'Unable to open the network connection profile.',
		1206 => 'The network connection profile is damaged.',
		1207 => 'Cannot enumerate a non-container.',
		1208 => 'An extended error has occurred.',
		1209 => 'The format of the specified group name is invalid.',
		1210 => 'The format of the specified computer name is invalid.',
		1211 => 'The format of the specified event name is invalid.',
		1212 => 'The format of the specified domain name is invalid.',
		1213 => 'The format of the specified service name is invalid.',
		1214 => 'The format of the specified network name is invalid.',
		1215 => 'The format of the specified share name is invalid.',
		1216 => 'The format of the specified password is invalid.',
		1217 => 'The format of the specified message name is invalid.',
		1218 => 'The format of the specified message destination is invalid.',
		1219 => 'The credentials supplied conflict with an existing set of credentials.',
		1220 => 'An attempt was made to establish a session to a LAN Manager server, but there are already too many sessions established to that server.',
		1221 => 'The workgroup or domain name is already in use by another computer on the network.',
		1222 => 'The network is not present or not started.',
		1223 => 'The operation was cancelled by the user.',
		1224 => 'The requested operation cannot be performed on a file with a user mapped section open.',
		1225 => 'The remote system refused the network connection.',
		1226 => 'The network connection was gracefully closed.',
		1227 => 'The network transport endpoint already has an address associated with it.',
		1228 => 'An address has not yet been associated with the network endpoint.',
		1229 => 'An operation was attempted on a non-existent network connection.',
		1230 => 'An invalid operation was attempted on an active network connection.',
		1231 => 'The remote network is not reachable by the transport.',
		1232 => 'The remote system is not reachable by the transport.',
		1233 => 'The remote system does not support the transport protocol.',
		1234 => 'No service is operating at the destination network endpoint on the remote system.',
		1235 => 'The request was aborted.',
		1236 => 'The network connection was aborted by the local system.',
		1237 => 'The operation could not be completed.  A retry should be performed.',
		1238 => 'A connection to the server could not be made because the limit on the number of concurrent connections for this account has been reached.',
		1239 => 'Attempting to login during an unauthorized time of day for this account.',
		1240 => 'The account is not authorized to login from this station.',
		1241 => 'The network address could not be used for the operation requested.',
		1242 => 'The service is already registered.',
		1243 => 'The specified service does not exist.',
		1244 => 'The operation being requested was not performed because the user has not been authenticated.',
		1245 => 'The operation being requested was not performed because the user has not logged on to the network.',
		1246 => 'Return that wants caller to continue with work in progress.',
		1247 => 'An attempt was made to perform an initialization operation when initialization has already been completed.',
		1248 => 'No more local devices.',
		1300 => 'Indicates not all privileges referenced are assigned to the caller. This allows, for example, all privileges to be disabled without having to know exactly which privileges are assigned.',
		1301 => 'Some of the information to be mapped has not been translated.',
		1302 => 'No system quota limits are specifically set for this account.',
		1303 => 'A user session key was requested for a local RPC connection. The session key returned is a constant value and not unique to this connection.',
		1304 => 'The Windows NT password is too complex to be converted to a Windows-networking password. The Windows-networking password returned is a NULL string.',
		1305 => 'Indicates an encountered or specified revision number is not one known by the service. The service may not be aware of a more recent revision.',
		1306 => 'Indicates two revision levels are incompatible.',
		1307 => 'Indicates a particular Security ID cannot be assigned as the owner of an object.',
		1308 => 'Indicates a particular Security ID cannot be assigned as the primary group of an object.',
		1309 => 'An attempt was made to operate on an impersonation token by a thread was not currently impersonating a client.',
		1310 => 'A mandatory group cannot be disabled.',
		1311 => 'There are currently no logon servers available to service the logon request.',
		1312 => 'A specified logon session does not exist. It may already have been terminated.',
		1313 => 'A specified privilege does not exist.',
		1314 => 'A required privilege is not held by the client.',
		1315 => 'The name provided is not a properly formed account name.',
		1316 => 'The specified user already exists.',
		1317 => 'The specified user does not exist.',
		1318 => 'The specified group already exists.',
		1319 => 'The specified group does not exist.',
		1320 => 'The specified user account is already in the specified group account. Also used to indicate a group can not be deleted because it contains a member.',
		1321 => 'The specified user account is not a member of the specified group account.',
		1322 => 'Indicates the requested operation would disable or delete the last remaining administration account. This is not allowed to prevent creating a situation where the system will not be administrable.',
		1323 => 'When trying to update a password, this return status indicates the value provided as the current password is incorrect.',
		1324 => 'When trying to update a password, this return status indicates the value provided for the new password contains values not allowed in passwords.',
		1325 => 'When trying to update a password, this status indicates that some password update rule was violated. For example, the password may not meet length criteria.',
		1326 => 'The attempted logon is invalid. This is due to either a bad user name or authentication information.',
		1327 => 'Indicates a referenced user name and authentication information are valid, but some user account restriction has prevented successful authentication (such as time-of-day restrictions).',
		1328 => 'The user account has time restrictions and cannot be logged onto at this time.',
		1329 => 'The user account is restricted and cannot be used to log on from the source workstation.',
		1330 => 'The user account\'s password has expired.',
		1331 => 'The referenced account is currently disabled and cannot be logged on to.',
		1332 => 'None of the information to be mapped has been translated.',
		1333 => 'The number of LUIDrequested cannot be allocated with a single allocation.',
		1334 => 'Indicates there are no more LUIDto allocate.',
		1335 => 'Indicates the sub-authority value is invalid for the particular use.',
		1336 => 'Indicates the ACL structure is not valid.',
		1337 => 'Indicates the SIDstructure is invalid.',
		1338 => 'Indicates the SECURITY_DESCRIPTOR structure is invalid.',
		1340 => 'Indicates that an attempt to build either an inherited ACL or ACE did not succeed. One of the more probable causes is the replacement of a CreatorId with an SID that didn\'t fit into the ACE or ACL.',
		1341 => 'The GUID allocation server is already disabled at the moment.',
		1342 => 'The GUID allocation server is already enabled at the moment.',
		1343 => 'The value provided is an invalid value for an identifier authority.',
		1344 => 'When a block of memory is allotted for future updates, such as the memory allocated to hold discretionary access control and primary group information, successive updates may exceed the amount of memory originally allotted. Since quota may already have been charged to several processes that have handles of the object, it is not reasonable to alter the size of the allocated memory. Instead, a request that requires more memory than has been allotted must fail and the ERROR_ALLOTTED_SPACE_EXCEEDED error returned.',
		1345 => 'The specified attributes are invalid, or incompatible with the attributes for the group as a whole.',
		1346 => 'A specified impersonation level is invalid. Also used to indicate a required impersonation level was not provided.',
		1347 => 'An attempt was made to open an anonymous level token. Anonymous tokens cannot be opened.',
		1348 => 'The requested validation information class is invalid.',
		1349 => 'The type of token object is inappropriate for its attempted use.',
		1350 => 'Indicates an attempt was made to operate on the security of an object that does not have security associated with it.',
		1351 => 'Indicates a domain controller could not be contacted or that objects within the domain are protected and necessary information could not be retrieved.',
		1352 => 'Indicates the Sam Server was in the wrong state to perform the desired operation.',
		1353 => 'Indicates the domain is in the wrong state to perform the desired operation.',
		1354 => 'Indicates the requested operation cannot be completed with the domain in its present role.',
		1355 => 'The specified domain does not exist.',
		1356 => 'The specified domain already exists.',
		1357 => 'An attempt to exceed the limit on the number of domains per server for this release.',
		1358 => 'This error indicates the requested operation cannot be completed due to a catastrophic media failure or on-disk data structure corruption.',
		1359 => 'This error indicates the SAM server has encounterred an internal consistency error in its database. This catastrophic failure prevents further operation of SAM.',
		1360 => 'Indicates generic access types were contained in an access mask that should already be mapped to non-generic access types.',
		1361 => 'Indicates a security descriptor is not in the required format (absolute or self-relative).',
		1362 => 'The requested action is restricted for use by logon processes only. The calling process has not registered as a logon process.',
		1363 => 'An attempt was made to start a new session manager or LSA logon session with an ID already in use.',
		1364 => 'A specified authentication package is unknown.',
		1365 => 'The logon session is not in a state consistent with the requested operation.',
		1366 => 'The logon session ID is already in use.',
		1367 => 'Indicates an invalid value has been provided for LogonType has been requested.',
		1368 => 'Indicates that an attempt was made to impersonate via a named pipe was not yet read from.',
		1369 => 'Indicates that the transaction state of a registry sub-tree is incompatible with the requested operation. For example, a request has been made to start a new transaction with one already in progress, or a request to apply a transaction when one is not currently in progress. This status value is returned by the runtime library (RTL) registry transaction package (RXact).',
		1370 => 'Indicates an error occurred during a registry transaction commit. The database has been left in an unknown state. The state of the registry transaction is left as COMMITTING. This status value is returned by the runtime library (RTL) registry transaction package (RXact).',
		1371 => 'Indicates an operation was attempted on a built-in (special) SAM account that is incompatible with built-in accounts. For example, built-in accounts cannot be renamed or deleted.',
		1372 => 'The requested operation cannot be performed on the specified group because it is a built-in special group.',
		1373 => 'The requested operation cannot be performed on the specified user because it is a built-in special user.',
		1374 => 'Indicates a member cannot be removed from a group because the group is currently the member\'s primary group.',
		1375 => 'An attempt was made to establish a token for use as a primary token but the token is already in use. A token can only be the primary token of one process at a time.',
		1376 => 'The specified alias does not exist.',
		1377 => 'The specified account name is not a member of the alias.',
		1378 => 'The specified account name is not a member of the alias.',
		1379 => 'The specified alias already exists.',
		1380 => 'A requested type of logon, such as Interactive, Network, or Service, is not granted by the target system\'s local security policy. The system administrator can grant the required form of logon.',
		1381 => 'The maximum number of secrets that can be stored in a single system was exceeded. The length and number of secrets is limited to satisfy the United States State Department export restrictions.',
		1382 => 'The length of a secret exceeds the maximum length allowed. The length and number of secrets is limited to satisfy the United States State Department export restrictions.',
		1383 => 'The Local Security Authority (LSA) database contains in internal inconsistency.',
		1384 => 'During a logon attempt, the user\'s security context accumulated too many security IDs. Remove the user from some groups or aliases to reduce the number of security ids to incorporate into the security context.',
		1385 => 'A user has requested a type of logon, such as interactive or network, that was not granted.  An administrator has control over who may logon interactively and through the network.',
		1386 => 'An attempt was made to change a user password in the security account manager without providing the necessary NT cross-encrypted password.',
		1387 => 'A new member cannot be added to an alias because the member does not exist.',
		1388 => 'A new member could not be added to an alias because the member has the wrong account type.',
		1389 => 'Too many SIDs specified.',
		1390 => 'An attempt was made to change a user password in the security account manager without providing the required LM cross-encrypted password.',
		1391 => 'Indicates an ACL contains no inheritable components.',
		1392 => 'The file or directory is damaged and nonreadable.',
		1393 => 'The disk structure is damaged and nonreadable.',
		1394 => 'There is no user session key for the specified logon session.',
		1395 => 'The service being accessed is licensed for a particular number of connections. No more connections can be made to the service at this time because there are already as many connections as the service can accept.',
		1400 => 'The window handle invalid.',
		1401 => 'The menu handle is invalid.',
		1402 => 'The cursor handle is invalid.',
		1403 => 'Invalid accelerator-table handle.',
		1404 => 'The hook handle is invalid.',
		1405 => 'The DeferWindowPoshandle is invalid.',
		1406 => 'CreateWindow failed, creating top-level window with WS_CHILDstyle.',
		1407 => 'Cannot find window class.',
		1408 => 'Invalid window, belongs to other thread.',
		1409 => 'Hotkey is already registered.',
		1410 => 'Class already exists.',
		1411 => 'Class does not exist.',
		1412 => 'Class still has open windows.',
		1413 => 'The index is invalid.',
		1414 => 'The icon handle is invalid.',
		1415 => 'Using private DIALOG window words.',
		1416 => 'List box ID not found.',
		1417 => 'No wildcard characters found.',
		1418 => 'Thread doesn\'t have clipboard open.',
		1419 => 'Hotkey is not registered.',
		1420 => 'The window is not a valid dialog window.',
		1421 => 'Control ID not found.',
		1422 => 'Invalid Message, combo box doesn\'t have an edit control.',
		1423 => 'The window is not a combo box.',
		1424 => 'Height must be less than 256.',
		1425 => 'Invalid HDC passed to ReleaseDC.',
		1426 => 'The hook filter type is invalid.',
		1427 => 'The filter proc is invalid.',
		1428 => 'Cannot set non-local hook without an module handle.',
		1429 => 'This hook can only be set globally.',
		1430 => 'The journal hook is already installed.',
		1431 => 'Hook is not installed.',
		1432 => 'The message for single-selection list box is invalid.',
		1433 => 'LB_SETCOUNT sent to non-lazy list box.',
		1434 => 'This list box doesn\'t support tab stops.',
		1435 => 'Cannot destroy object created by another thread.',
		1436 => 'Child windows can\'t have menus.',
		1437 => 'Window does not have system menu.',
		1438 => 'The message box style is invalid.',
		1439 => 'The SPI_* parameter is invalid.',
		1440 => 'Screen already locked.',
		1441 => 'All DeferWindowPosHWNDs must have same parent.',
		1442 => 'Window is not a child window.',
		1443 => 'The GW_* command is invalid.',
		1444 => 'The thread ID is invalid.',
		1445 => 'DefMDIChildProccalled with a non-MDI child window.',
		1446 => 'Pop-up menu already active.',
		1447 => 'Window does not have scroll bars.',
		1448 => 'Scrollbar range greater than 0x7FFF.',
		1449 => 'The ShowWindowcommand is invalid.',
		1450 => 'Insufficient system resources exist to complete the requested service.',
		1451 => 'Insufficient system resources exist to complete the requested service.',
		1452 => 'Insufficient system resources exist to complete the requested service.',
		1453 => 'Insufficient quota to complete the requested service.',
		1454 => 'Insufficient quota to complete the requested service.',
		1455 => 'The paging file is too small for this operation to complete.',
		1456 => 'A menu item was not found.',
		1457 => 'Invalid keyboard layout handle.',
		1458 => 'Hook type not allowed.',
		1500 => 'One of the Eventlog logfiles is damaged.',
		1501 => 'No event log file could be opened, so the event logging service did not start.',
		1502 => 'The event log file is full.',
		1503 => 'The event log file has changed between reads.',
		1700 => 'The string binding is invalid.',
		1701 => 'The binding handle is the incorrect type.',
		1702 => 'The binding handle is invalid.',
		1703 => 'The RPC protocol sequence is not supported.',
		1704 => 'The RPC protocol sequence is invalid.',
		1705 => 'The string UUID is invalid.',
		1706 => 'The endpoint format is invalid.',
		1707 => 'The network address is invalid.',
		1708 => 'No endpoint was found.',
		1709 => 'The timeout value is invalid.',
		1710 => 'The object UUID was not found.',
		1711 => 'The object UUID already registered.',
		1712 => 'The type UUID is already registered.',
		1713 => 'The server is already listening.',
		1714 => 'No protocol sequences were registered.',
		1715 => 'The server is not listening.',
		1716 => 'The manager type is unknown.',
		1717 => 'The interface is unknown.',
		1718 => 'There are no bindings.',
		1719 => 'There are no protocol sequences.',
		1720 => 'The endpoint cannot be created.',
		1721 => 'Not enough resources are available to complete this operation.',
		1722 => 'The server is unavailable.',
		1723 => 'The server is too busy to complete this operation.',
		1724 => 'The network options are invalid.',
		1725 => 'There is not a remote procedure call active in this thread.',
		1726 => 'The remote procedure call failed.',
		1727 => 'The remote procedure call failed and did not execute.',
		1728 => 'An RPC protocol error occurred.',
		1730 => 'The transfer syntax is not supported by the server.',
		1731 => 'The server has insufficient memory to complete this operation.',
		1732 => 'The type UUID is not supported.',
		1733 => 'The tag is invalid.',
		1734 => 'The array bounds are invalid.',
		1735 => 'The binding does not contain an entry name.',
		1736 => 'The name syntax is invalid.',
		1737 => 'The name syntax is not supported.',
		1739 => 'No network address is available to use to construct a UUID.',
		1740 => 'The endpoint is a duplicate.',
		1741 => 'The authentication type is unknown.',
		1742 => 'The maximum number of calls is too small.',
		1743 => 'The string is too long.',
		1744 => 'The RPC protocol sequence was not found.',
		1745 => 'The procedure number is out of range.',
		1746 => 'The binding does not contain any authentication information.',
		1747 => 'The authentication service is unknown.',
		1748 => 'The authentication level is unknown.',
		1749 => 'The security context is invalid.',
		1750 => 'The authorization service is unknown.',
		1751 => 'The entry is invalid.',
		1752 => 'The operation cannot be performed.',
		1753 => 'There are no more endpoints available from the endpoint mapper.',
		1755 => 'The entry name is incomplete.',
		1756 => 'The version option is invalid.',
		1757 => 'There are no more members.',
		1758 => 'There is nothing to unexport.',
		1759 => 'The interface was not found.',
		1760 => 'The entry already exists.',
		1761 => 'The entry is not found.',
		1762 => 'The name service is unavailable.',
		1764 => 'The requested operation is not supported.',
		1765 => 'No security context is available to allow impersonation.',
		1766 => 'An internal error occurred in RPC.',
		1767 => 'The server attempted an integer divide by zero.',
		1768 => 'An addressing error occurred in the server.',
		1769 => 'A floating point operation at the server caused a divide by zero.',
		1770 => 'A floating point underflow occurred at the server.',
		1771 => 'A floating point overflow occurred at the server.',
		1772 => 'The list of servers available for auto_handle binding was exhausted.',
		1773 => 'The file designated by DCERPCCHARTRANS cannot be opened.',
		1774 => 'The file containing the character translation table has fewer than 512 bytes.',
		1775 => 'A null context handle is passed as an [in] parameter.',
		1776 => 'The context handle does not match any known context handles.',
		1777 => 'The context handle changed during a call.',
		1778 => 'The binding handles passed to a remote procedure call do not match.',
		1779 => 'The stub is unable to get the call handle.',
		1780 => 'A null reference pointer was passed to the stub.',
		1781 => 'The enumeration value is out of range.',
		1782 => 'The byte count is too small.',
		1783 => 'The stub received bad data.',
		1784 => 'The supplied user buffer is invalid for the requested operation.',
		1785 => 'The disk media is not recognized. It may not be formatted.',
		1786 => 'The workstation does not have a trust secret.',
		1787 => 'The domain controller does not have an account for this workstation.',
		1788 => 'The trust relationship between the primary domain and the trusted domain failed.',
		1789 => 'The trust relationship between this workstation and the primary domain failed.',
		1790 => 'The network logon failed.',
		1791 => 'A remote procedure call is already in progress for this thread.',
		1792 => 'An attempt was made to logon, but the network logon service was not started.',
		1793 => 'The user\'s account has expired.',
		1794 => 'The redirector is in use and cannot be unloaded.',
		1795 => 'The specified printer driver is already installed.',
		1796 => 'The specified port is unknown.',
		1797 => 'The printer driver is unknown.',
		1798 => 'The print processor is unknown.',
		1799 => 'The specified separator file is invalid.',
		1800 => 'The specified priority is invalid.',
		1801 => 'The printer name is invalid.',
		1802 => 'The printer already exists.',
		1803 => 'The printer command is invalid.',
		1804 => 'The specified datatype is invalid.',
		1805 => 'The Environment specified is invalid.',
		1806 => 'There are no more bindings.',
		1807 => 'The account used is an interdomain trust account. Use your normal user account or remote user account to access this server.',
		1808 => 'The account used is a workstation trust account. Use your normal user account or remote user account to access this server.',
		1809 => 'The account used is an server trust account. Use your normal user account or remote user account to access this server.',
		1810 => 'The name or security ID (SID) of the domain specified is inconsistent with the trust information for that domain.',
		1811 => 'The server is in use and cannot be unloaded.',
		1812 => 'The specified image file did not contain a resource section.',
		1813 => 'The specified resource type can not be found in the image file.',
		1814 => 'The specified resource name can not be found in the image file.',
		1815 => 'The specified resource language ID cannot be found in the image file.',
		1816 => 'Not enough quota is available to process this command.',
		1817 => ' ',
		1818 => 'The server was altered while processing this call.',
		1819 => 'The binding handle does not contain all required information.',
		1820 => 'Communications failure.',
		1821 => 'The requested authentication level is not supported.',
		1822 => 'No principal name registered.',
		1823 => 'The error specified is not a valid Windows RPC error code.',
		1824 => 'A UUID that is valid only on this computer has been allocated.',
		1825 => 'A security package specific error occurred.',
		1826 => 'Thread is not cancelled.',
		1827 => 'Invalid operation on the encoding/decoding handle.',
		1828 => 'Incompatible version of the serializing package.',
		1829 => 'Incompatible version of the RPC stub.',
		1830 => 'The idl pipe object is invalid or corrupted.',
		1831 => 'The operation is invalid for a given idl pipe object.',
		1832 => 'The idl pipe version is not supported.',
		1898 => 'The group member was not found.',
		1899 => 'The endpoint mapper database could not be created.',
		1900 => 'The object universal unique identifier (UUID) is the nil UUID.',
		1901 => 'The specified time is invalid.',
		1902 => 'The specified Form name is invalid.',
		1903 => 'The specified Form size is invalid',
		1904 => 'The specified Printer handle is already being waited on',
		1905 => 'The specified Printer has been deleted',
		1906 => 'The state of the Printer is invalid',
		1907 => 'The user must change his password before he logs on the first time.',
		1908 => 'Could not find the domain controller for this domain.',
		1909 => 'The referenced account is currently locked out and may not be logged on to.',
		1910 => 'The object exporter specified was not found.',
		1911 => 'The object specified was not found.',
		1912 => 'The object resolver set specified was not found.',
		1913 => 'Some data remains to be sent in the request buffer.',
		2000 => 'The pixel format is invalid.',
		2001 => 'The specified driver is invalid.',
		2002 => 'The window style or class attribute is invalid for this operation.',
		2003 => 'The requested metafile operation is not supported.',
		2004 => 'The requested transformation operation is not supported.',
		2005 => 'The requested clipping operation is not supported.',
		2138 => 'The network is not present or not started.',
		2202 => 'The specified user name is invalid.',
		2250 => 'This network connection does not exist.',
		2401 => 'There are open files or requests pending on this connection.',
		2402 => 'Active connections still exist.',
		2404 => 'The device is in use by an active process and cannot be disconnected.',
		3000 => 'The specified print monitor is unknown.',
		3001 => 'The specified printer driver is currently in use.',
		3002 => 'The spool file was not found.',
		3003 => 'A StartDocPrinter call was not issued.',
		3004 => 'An AddJob call was not issued.',
		3005 => 'The specified print processor has already been installed.',
		3006 => 'The specified print monitor has already been installed.',
		3007 => 'The specified print monitor does not have the required functions.',
		3008 => 'The specified print monitor is currently in use.',
		3009 => 'The requested operation is not allowed when there are jobs queued to the printer.',
		3010 => 'The requested operation is successful. Changes will not be effective until the system is rebooted.',
		3011 => 'The requested operation is successful. Changes will not be effective until the service is restarted.',
		4000 => 'WINS encountered an error while processing the command.',
		4001 => 'The local WINS can not be deleted.',
		4002 => 'The importation from the file failed.',
		4003 => 'The backup failed. Was a full backup done before ?',
		4004 => 'The backup failed. Check the directory that you are backing the database to.',
		4005 => 'The name does not exist in the WINS database.',
		4006 => 'Replication with a non-configured partner is not allowed.',
		6118 => 'The list of servers for this workgroup is not currently available.');
	return "$error{$msg}";
}