# todo: learn about functions and apply to this linear script
# todo: make these cmd line args

# Checkout folder
repoPath = 'C:/Dev/aws/'
# Relative path to parameters file. Use forward slashes. Change to your domain!
configRelPath = 'cloudformation/testing/oracle-dev-domain-XXXYYYZZZ/private.parameters.json'
# Change to your instance identifier
instanceName = 'InstanceOfYourDBIdentifier'
snapshotIdentifier = 'production-respawn-oracle-vanessa';

# Create or checkout the Respawn branch
print('Checking repo')
import git
from git import Repo
repo = Repo(repoPath);
assert not repo.bare

print('Switching to Respawn branch')
try:
  branch = repo.git.checkout('Respawn')
except git.exc.GitCommandError:
  branch = repo.create_head('Respawn').checkout()

print('Bringing branch up to date')

# Make sure master and our branch are up to date
repo.git.fetch('upstream', 'master:master')
origin = repo.remotes['origin']
origin.push(refspec='master:master')
repo.git.rebase('master')

print('Fetching list of snapshots from AWS')

# Call aws to get a list of snapshots
import subprocess
awsCommand = 'aws --profile production --region eu-west-1 rds describe-db-snapshots --db-instance-identifier ' + snapshotIdentifier + ' --output text --query "DBSnapshots[*].{X:DBSnapshotIdentifier}"'
try:
  snapshots = subprocess.check_output(awsCommand)
except:
  print('Failed to get the list of snapshots.')
  exit(1);
  
snapshotList = sorted(snapshots.decode('utf-8').replace('\r', '').split('\n'), reverse=True)

# filter the snapshots to only get the gp2 types
# todo: make optional input parameter to allow other types as well
latestSnapshot = next((i for i in snapshotList if i.endswith('-gp2')), None)

assert not (latestSnapshot == None)

print('Checking config file')

# Load the oracle configuration for our domain-sd
import json
# to-do. Make this path an input parameter to make the script usable for other teams

configFilename = repoPath + configRelPath
with open(configFilename) as configFile:
  config = json.load(configFile)
  for p in config:
    if p['ParameterKey'] == instanceName:
      previousSnapshot = p['ParameterValue']
      p['ParameterValue'] = latestSnapshot

if previousSnapshot == latestSnapshot:
  print('Snapshot is up to date. Nothing to do.')
else:
  print('Old snapshot: ' + previousSnapshot)
  print('New snapshot: ' + latestSnapshot)

  # Write the config back to the file
  with open(configFilename, 'w') as configFile:
    json.dump(config, configFile, indent=2)
    configFile.close()

  print('Committing and pushing')

  # Commit, if the file has actually changed
  changed = [item.a_path for item in repo.index.diff(None)]
  if configRelPath in changed:
    repo.git.add(configRelPath)
    repo.index.commit('Respawn Oracle dev database')
  
print('Current snapshot: ' + latestSnapshot)

# Push to origin
origin.push(force=True, refspec='Respawn:Respawn');

