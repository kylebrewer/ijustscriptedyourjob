# ijustscriptedyourjob
This is a simple bash script to clone/pull from a git repository to an OS X client.  You could easily use this to maintain updated, local copies of support scripts on each OS X client in your organization.  Invoke the script from cron, and you've just automated a lazy admin's job.

The script does the following:
  Determine whether or not git is installed.
  If git is not installed, install Apple's Command Line Tools package to get it.
  Clone the git repository.
  On subsequent runs, pull updates if the previous clone's .git is present.
