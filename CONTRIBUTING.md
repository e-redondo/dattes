# Contributing to DATTES

If you'd like to contribute to DATTES (thanks!), please have a look at the [guidelines below](#workflow).

If you're already familiar with our workflow, maybe have a quick look at the [pre-commit checks](#pre-commit-checks) directly below.

## Pre-commit checks

Before you commit any code, please perform the following checks:

- [No code issues](#coding-style-guidelines): `checkcode('your_new_code_functions.m')`
- [All tests pass](#testing): `  ` (GNU/Linux and MacOS), ` ` (Windows)


## Workflow

We use [GIT](https://en.wikipedia.org/wiki/Git) and [GitLab](https://en.wikipedia.org/wiki/GitLab) to coordinate our work. When making any kind of update, we try to follow the procedure below.

### A. Before you begin

1. Create an [issue](https://gitlab.com/dattes/dattes/-/issues) where new proposals can be discussed before any coding is done.
2. Create a [branch](https://docs.gitlab.com/ee/user/project/repository/branches/) of this repo (ideally on your own [fork](https://docs.gitlab.com/ee/user/project/repository/forking_workflow.html)), where all changes will be made
3. Download the source code onto your local system, by [cloning](https://docs.gitlab.com/ee/user/project/repository/) the repository (or your fork of the repository).
4. [Install](https://dattes.gitlab.io/page/documentation/getting_started/) DATTES.
5. [Test](#testing) if your installation worked, using the test function: ` `.

You now have everything you need to start making changes!

### B. Writing your code

6. DATTES is developed in [Matlab ](https://en.wikipedia.org/wiki/MATLAB)). All its features are also available with [GNU Octave](https://en.wikipedia.org/wiki/GNU_Octave)
7. Make sure to follow our [coding style guidelines](#coding-style-guidelines).
8. Commit your changes to your branch with [useful, descriptive commit messages](https://chris.beams.io/posts/git-commit/): Remember these are publicly visible and should still make sense a few months ahead in time. While developing, you can keep using the Gitlab issue you're working on as a place for discussion. [Refer to your commits](https://stackoverflow.com/questions/8910271/how-can-i-reference-a-commit-in-an-issue-comment-on-github) when discussing specific lines of code.
9. If you want to add a dependency on another library, or re-use code you found somewhere else, have a look at [these guidelines](#dependencies-and-reusing-code).

### C. Merging your changes with DATTES

10. [Test your code!](#testing)
11. DATTES has online documentation at https://dattes.gitlab.io/. To make sure any new methods or classes you added show up there, please read the [documentation](#documentation) section.
12. If you added a major new feature, perhaps it should be showcased in an [example notebook](#example-notebooks).
13. When you feel your code is finished, or at least warrants serious discussion, run the [pre-commit checks](#pre-commit-checks) and then [push your improvement](https://docs.gitlab.com/ee/user/project/push_options.html)  on [DATTE's Gitlab page](https://gitlab.com/dattes/dattes).
14. Once a push request has been created, it will be reviewed by any member of the community. Changes might be suggested which you can make by simply adding new commits to the branch. When everything's finished, someone with the right Gitlab permissions will merge your changes into DATTES main repository.




## Coding guidelines

DATTES follows the [Matlab coding recommendations](https://www.mathworks.com/matlabcentral/fileexchange/22943-guidelines-for-writing-clean-and-fast-code-in-matlab) for coding style. These are very common guidelines, and community tools have been developed to check how well projects implement them.

### Naming
In DATTES, naming is aimed to be as descriptive and short as possible. 
[Snake case](https://en.wikipedia.org/wiki/Snake_case) is used to name the variables, arrays, structures and functions. Using abbreviations is avoided when possible without making names overly long.


## Dependencies and reusing code

While it's a bad idea for developers to "reinvent the wheel", it's important for users to get a _reasonably sized download and a free and easy install_. External libraries can sometimes be not free or cease to be supported. For these reasons, all dependencies in DATTES should be thought about carefully, and discussed on Gitlab.


## Testing

All code requires testing. These tests typically just check that the code runs without error, and so, are more _debugging_ than _testing_ in a strict sense. Nevertheless, they are very useful to have!


### Writing tests

Every new feature should have its own test. To create ones, have a look at the `tests` directory and see if there's a test for a similar method. Copy-pasting this is a good way to start.

Next, add some simple (and speedy!) tests of your main features. If these run without exceptions that's a good start! Next, check the output of your methods using any of these [assert methods](https://www.mathworks.com/help/matlab/ref/assert.html).



### Debugging

Often, the code you write won't pass the tests straight away, at which stage it will become necessary to debug.
The key to successful debugging is to isolate the problem by finding the smallest possible example that causes the bug.
In practice, there are a few tricks to help you to do this, which are described [here](https://www.mathworks.com/help/matlab/matlab_prog/debugging-process-and-features.html).

Once you've isolated the issue, it's a good idea to add a unit test that replicates this issue, so that you can easily check whether it's been fixed, and make sure that it's easily picked up if it crops up again.
This also means that, if you can't fix the bug yourself, it will be much easier to ask for help (by opening a [bug-report issue](https://gitlab.com/dattes/dattes/-/issues/new)).




### Profiling

Sometimes, a bit of code will take much longer than you expect to run. In this case, you can follow [these instructions][https://www.mathworks.com/help/matlab/matlab_prog/profiling-for-improving-performance.html) to fix this.


## Documentation

DATTES is documented in several ways.

First and foremost, every method and every class should have a [help](https://www.mathworks.com/help/matlab/matlab_prog/add-help-for-your-program.html) that describes in plain terms what it does, and what the expected input and output is.

 For example, here is the dattes.m help :
 
 
 ```
 %DATTES Data Analysis Tools for Tests on Energy Storage
%
% [result] = dattes(xml_file,options,cfg_file):
% Read the *.xml file of a battery test and performe several calculations
% (Capacity, SoC, OCV, impedance identification, ICA/DVA, etc.).
% Results are returned as output variables and (optionally) stored in a file
% named 'xml_file_result.mat'.
%
% Usage:
% [result] = dattes(xml_file,options,cfg_file)
% Inputs : 
% - xml_file:
%     -   [1xn string]: pathame to the xml file
%     -   [nx1 cell string]: xml filelist
% - options:  [1xn string] string containing execution options:
%   -'g': show figures
%   -'s': save result, config, phases >>> 'xml_file_result.mat'.
%   -'f': force, redo the actions even if the result file already exists
%   -'u': update, redo the actions even if the xml_file is more recent
%   -'v': verbose, tell what you do
%   -'c': run the configuration following cfg_file
%   -'e': EIS (plot_eis)
%   -'C': Capacity measurement
%   -'S': SoC calculation
%   -'R': Resistance identification
%   -'Z': impedance identification (CPE, Warburg or other)
%   -'P': pseudoOCV (low current charge/discharge cycles)
%   -'O': OCV by points (partial charge/discharges followed by rests)
%   -'I': ICA/DVA
%   -'A': synonym for 'CSRWPOI' (do all)
%   -'G': visualize the resuls obtained before (stored in 'xml_file_result.mat')
%     - 'Gx': visualize extracted profiles (t,U,I)
%     - 'Gp': visualize phase decomposition
%     - 'Gc': visualize configuration
%     - 'GS': visualize soc
%     - 'GC': visualize capacity
%     - 'GP': visualize pseudoOCV
%     - 'GO': visualize OCV by points
%     - 'GE': visualize efficiency
%     - 'GR': visualize resistance
%     - 'GW': visualize CPE impedance
%     - 'G*d': time in days (* = x,p,c,S,C,R,W,P,O,I)
%     - 'G*h': time in hours (* = x,p,c,S,C,R,W,P,O,I)
%     - 'G*D': time as date/time (* = x,p,c,S,C,R,W,P,O,I)
% - cfg_file:  [1x1 struct] function name to configure the behavior (see configurator)
%
% Outputs : 
% - result: [1x1 struct] structure containing the following fields:
%     - configuration [1x1 struct] configuration parameters
%     - test [1x1 struct] general information about the test
%     - phases [px1 struct] structure array with basic information about the different phases of the test
%
% Examples:
% dattes(xml_file,'s',cfg_file): Load the profiles (t,U,I,m) in .xml file and save them in a xml_file_result.mat.
% dattes(xml_file,'gs',cfg_file): idem and plot profiles graphs
% dattes(xml_file,'gsv',cfg_file): idem and describe ongoing analysis (verbose)
%
% dattes(xml_file,'ps',cfg_file), split the test in phases and save
% dattes(xml_file,'cs',cfg_file), configure the test and save
%
% [result] = dattes(xml_file), load the results
%
% dattes(xml_file,'C'), make capacity analysis.
%
% dattes(xml_file,'Cs'), idem and save results in a xml_file_results.mat.
%
% dattes(xml_file,'As'), Do all analysis : load, configuration all
% analysis and save results in a xml_file_results.mat.
%
%
% See also extract_profiles, split_phases, configurator
% ident_capacity, ident_ocv_by_points, ident_pseudo_ocv, ident_r, ident_cpe, ident_rrc, ident_ica
%
%
% Copyright 2015 DATTES_Contributors <dattes@univ-eiffel.fr> .
% For more information, see the <a href="matlab: 
% web('https://gitlab.com/dattes/dattes/-/blob/main/LICENSE')">DATTES License</a>.

 ```


 [The documentation site](https://dattes.gitlab.io/) describes in details the role, the methodology and the hypothesis used for each main functions.


### Example notebooks

Major DATTES features are showcased in [Jupyter notebooks](https://jupyter.org/) stored in the [examples directory](examples/notebooks). 



## Acknowledgements

This CONTRIBUTING.md file, along with large sections of the code infrastructure was copied from the excellent [Pints GitHub repo](https://github.com/pints-team/pints) and [Pybamm Github repo](https://github.com/pybamm-team/PyBaMM)

  