# Untitled



## Lightning Web Components Recipes

[!\[Github Workflow\]\(&lt;https://github.com/trailheadapps/lwc-recipes/workflows/Salesforce%20DX%20CI%20\(scratch%20org%20only\)/badge.svg?branch=master&gt;\)](https://github.com/trailheadapps/lwc-recipes/actions) [![codecov](https://codecov.io/gh/trailheadapps/lwc-recipes/branch/master/graph/badge.svg)](https://codecov.io/gh/trailheadapps/lwc-recipes)

![recipes-logo](recipes-logo.png)

A collection of easy-to-digest code examples for Lightning Web Components. Each recipe demonstrates how to code a specific task in 30 lines of code or less. A View Source link takes you right to the code in GitHub. From Hello World to data access and third-party libraries, there is a recipe for that!

> This sample application is designed to run on Salesforce Platform. If you want to experience Lightning Web Components on any platform, please visit [https://lwc.dev](https://lwc.dev), and try out our Lightning Web Components sample application [LWC Recipes OSS](https://github.com/trailheadapps/lwc-recipes-oss).

### Installation Instructions

There are two ways to install Lightning Web Components Recipes:

* Using a Scratch Org: This is the recommended installation option. Use this option if you are a developer who wants to experience the app and the code.
* Using an Unlocked Package: This option allows anybody to experience the sample app without installing a local development environment.

### Installing Recipes using a Scratch Org

1. Set up your environment. Follow the steps in the [Quick Start: Lightning Web Components](https://trailhead.salesforce.com/content/learn/projects/quick-start-lightning-web-components/) Trailhead project. The steps include:
2. Enable Dev Hub in your Trailhead Playground
3. Install Salesforce CLI
4. Install Visual Studio Code
5. Install the Visual Studio Code Salesforce extensions, including the Lightning Web Components extension
6. If you haven't already done so, authenticate with your hub org and provide it with an alias \(**myhuborg** in the command below\):

```text
sfdx force:auth:web:login -d -a myhuborg
```

1. Clone the lwc-recipes repository:

```text
git clone https://github.com/trailheadapps/lwc-recipes
cd lwc-recipes
```

1. Create a scratch org and provide it with an alias \(**lwc-recipes** in the command below\):

```text
sfdx force:org:create -s -f config/project-scratch-def.json -a lwc-recipes
```

1. Push the app to your scratch org:

```text
sfdx force:source:push
```

1. Assign the **recipes** permission set to the default user:

```text
sfdx force:user:permset:assign -n recipes
```

1. Load sample data:

```text
sfdx force:data:tree:import --plan ./data/data-plan.json
```

1. Open the scratch org:

```text
sfdx force:org:open
```

1. In **Setup**, under **Themes and Branding**, activate the **Recipes Lite** or **Recipes Blue** theme.
2. In App Launcher, select the **LWC** app.

### Installing Recipes using an Unlocked Package

1. [Sign up](https://developer.salesforce.com/signup) for a Developer Edition \(DE\) org.
2. Enable MyDomain in your DE org. Instructions to do this are [here](https://trailhead.salesforce.com/modules/identity_login/units/identity_login_my_domain).
3. Click [this link](https://login.salesforce.com/packaging/installPackage.apexp?p0=04tB0000000OEEdIAO) to install the Recipes unlocked package in your DE org.
4. Select **Install for All Users**
5. Import Account and Contacts data:
6. Click [here](https://raw.githubusercontent.com/trailheadapps/lwc-recipes/master/data/Accounts-Contacts.csv) to access the **Accounts-Contacts.csv** file. Right click on the browser window and save the file as **Accounts-Contacts.csv**.
7. In **Setup**, type **Data Import** in the Quick Find box and click **Data Import Wizard**.
8. Click **Launch Wizard**.
9. Click **Accounts and Contacts**, and click **Add New Records**.
10. Drag the **Accounts-Contacts.csv** file you just saved to the upload area.
11. Click **Next**, **Next**, and **Start Import**.
12. In **Setup**, under **Themes and Branding**, activate the **Recipes Lite** or **Recipes Blue** theme.
13. In App Launcher, select the **LWC** app.

### Optional Installation Instructions

This repository contains several files that are relevant if you want to integrate modern web development tooling to your Salesforce development processes, or to your continuous integration/continuous deployment processes.

#### Code formatting

[Prettier](https://prettier.io/) is a code formatter used to ensure consistent formatting across your code base. To use Prettier with Visual Studio Code, install [this extension](https://marketplace.visualstudio.com/items?itemName=esbenp.prettier-vscode) from the Visual Studio Code Marketplace. The [.prettierignore](/.prettierignore) and [.prettierrc](/.prettierrc) files are provided as part of this repository to control the behavior of the Prettier formatter.

#### Code linting

[ESLint](https://eslint.org/) is a popular JavaScript linting tool used to identify stylistic errors and erroneous constructs. To use ESLint with Visual Studio Code, install [this extension](https://marketplace.visualstudio.com/items?itemName=salesforce.salesforcedx-vscode-lwc) from the Visual Studio Code Marketplace. The [.eslintignore](/.eslintignore) file is provided as part of this repository to exclude specific files from the linting process in the context of Lightning Web Components development.

#### Pre-commit hook

This repository also comes with a [package.json](./package.json) file that makes it easy to set up a pre-commit hook that enforces code formatting and linting by running Prettier and ESLint every time you `git commit` changes.

To set up the formatting and linting pre-commit hook:

1. Install [Node.js](https://nodejs.org) if you haven't already done so
2. Run `npm install` in your project's root folder to install the ESLint and Prettier modules \(Note: Mac users should verify that Xcode command line tools are installed before running this command.\)

Prettier and ESLint will now run automatically every time you commit changes. The commit will fail if linting errors are detected. You can also run the formatting and linting from the command line using the following commands \(check out [package.json](./package.json) for the full list\):

```text
npm run lint:lwc
npm run prettier
```

