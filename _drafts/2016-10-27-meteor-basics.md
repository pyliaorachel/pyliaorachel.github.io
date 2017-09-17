---
layout: post
title:  "Meteor Basics"
categories: Blog Tech Meteor
tags: ["meteor"]
author: pyliaorachel
comments: true
excerpt_separator: <!--more-->
---

## Content

1. Meteor Scaffolding
2. Meteor Application Basics
3. Iron Router

<!--more-->
---
## Meteor Scaffolding

### Folder Structure

```
+-- server
|
+-- client
|
+-- model: client + server data
```

### Order of Execution

1. lib
2. sub folders
3. alphabet order
4. main.*

### Visibility Rules

- public/
	- static
	- visible content
- private/
	- static
	- server-visible (using `Assets`)
- client/compatibility/
	- legacy
	- makes `var` declarations visible
- [.anything]
	- hidden from server refresh

## Meteor Application Basics

### Create Meteor Applications

1. Create meteor project

	`meteor create [application-name]`  
	`cd [application-name]`  
	`meteor`

2. Setup folder structures
3. Knowing debugging tool
	- Console
	- Meteor Shell

### Meteor Packages

#### Commands

- `meteor list`
- `meteor search [author]`  
	or  
	https://atmospherejs.com
- `meteor add [package@=version]`
- `meteor remove [package@=version]`

#### Core Packages

- `autopublish`
- `insecure`
- `meteor-platform`

### Content & Display

#### Templates

- Template inclusion

	```
	// using_template.html

	{{> template_name}}
	```
	```
	// tmpl-template_name.html

	<template name="template_name"></template>
	```

#### Data

- Server `publishes` data

	```js
	// server.js

	Meteor.publish("collection", function() {
		// returns a cursor to collection
		return Collection.find({});
	})
	```

- Client `subscribes` data

	```js
	// client.js

	Meteor.subscribe('collection');
	```

- Loop through collection data

	```
	// tmpl-template_name.html

	{{#each collection}}
		<div class="collection_item">{{text}}</div>
	{{/each}}
	```
	- Define what `collection` give in template helpers!

- Template helpers
	- Update the content instantly

	```js
	// tmpl-template_name.js

	Template.collection.helpers({
		collection: function() {
			return Collection.find().fetch();
		},
		isLink: function() {
			// looping through data - this
			reutrn (this.URL != undefined);
		}
	});
	```
#### Events

- Template event handler
	
	```js
	// tmpl-template_name.js

	Template.template_name.events({
		'click #id': function(e) {
			// do something
		}
	});
	```

### Security

- Remove `insecure` package
- Server

	```js
	// server.js

	Meteor.publish("collection", function() {
		// returns a cursor to collection
		return Collection.find({owner:this.userId});
	})

	Collection.allow({
		insert: function(userId, fields) {
			return(userId); // allow insersion if userId !== null i.e. logged in
		}
	})
	```

- Client

	```js
	// tmpl-template_name.js

	Template.template_name.events({
		'click #id': function(e) {
			// do something
			Snippets.insert({
				owner: Meteor.userId(),
				...
			});
		}
	});	
	```

### Interacting with External Services

```js
// server.js of external service
// actually a DDP client listening to changes in remote server

var conn = DDP.connect('localhost:3000');
Collection = new Mongo.Collection('collection', conn); // the collection already exists and served by the connection

Tokens = new Mongo.Collection('user-tokens');

var token = Tokens.findOne({});

if (!token) {
	initLogin();
} else {
	loginWithToken(token);
}

if (token) {
	conn.subscribe('collection-admin', function() {
		Collection.find({}).observeChanges({ // add, edit, delete
			added: function(id, s) {
				// update s
				try {
					Collection.update({_id:id}, {$set: s});
				} catch(e) {
					// log error
				}
			}
		});
	});
}

function initLogin() {
	conn.call('login', {
		user: {email: 'admin@test.com'},
		password: 'psw'
	}, function(err, res) {
		if (err)
			// log error
		Token.upsert({userid: res.id}, {$set: res});
	});
}

funciton loginWithToken(token) {
	conn.call('login', {
		resume: token.token
	}, function(err, result) {
		if (err) {
			// log err
			Tokens.remove({});
			initLogin();
			return;
		} 
		Tokens.upsert({userid: res.id}, {$set: res});
	});
}
```
```js
// server.js of your own

...

Meteor.publish("collection-admin", function() {
	return Collection.find({});
})

Collection.allow({
	insert: function(userId, fields) {
		return(userId); // allow insersion if userId !== null i.e. logged in
	},
	update: function(userId, fields) {
		return(userId);
	}
})
```

`meteor --port 1234` on external service
`meteor reset` resets service

## [Iron Router](https://github.com/iron-meteor/iron-router)

### REST Endpoints

```js
// create a main template

Router.configure({
	layoutTemplate: 'main'
});
```
```js
// server/api/REST.js

Router.route('/api/', {
	where: 'server'
}).get(function() {
	// write headers
	writeHeaders(this);
	// send response
	this.response.end('message');
}).post(function() {
	writeHeaders(this);
	var useremail = this.request.body.email;

	if (!usermail) {
		// respond error message
		return;
	}

	// check if user exists
	var user = Meteor.users.findOne({
		emails: {
			$elemMatch: {
				address: useremail
			}
		}
	});

	if (!user) {
		// respond error message
		return;
	}

	var records = Collection.find({owner: user._id}).fetch();
	this.response.end(JSON.stringify(records));
}).put(function() {
	writeHeaders(this);

	// check if change parameters specified
	var record = this.request.body.update;

	if (!record) {
		// respond error message
		return;
	}

	var update = Collection.upsert({
		_id: record.id
	}, {
		$set: record.changes
	});
	this.response.end('message');
}).delete(function() {
	writeHeaders(this);

	// check if ID sent
	var recID = this.request.body.collectionID;
	if (!recID) {
		// respond error message
		return;	
	}

	var del = Collection.remove({_id: recID});
	this.response.end('message');
});

function writeHeaders(self) {
	self.response.statusCode = 200;
	self.response.setHeader('Content-Type', 'application/json');
	self.response.setHeader('Access-Control-Allow-Origin', '*');
	self.response.setHeader('Access-Control-Allow-Headers', 'Origin, X-Requested-With, Content-Type, Accept');
}
```

## UI with Mansonry

### `masonryContainer` & `masonryElement`

```
{{#masonryContainer id='MasonryContainer' columnWidth=25 gutter=4 transitionDuration='0.1s'}}
	// some element template
{{/masonryContainer}}
```
```
// inside element template
<template name='collection'>
	{{#masonryElement 'MasonryContainer'}}
	...
	{{/masonryElement}}
</template>
```

## Deployment

`meteor deploy [name.meteor.com]`

### Custom Server

- MUP
	`mup init` 

	```
	// mup.json
	{
		"servers": [
			{
				"host": "your-domain-name",
				...
			}
		],
		...,
		"env: {
			"ROOT_URL": "http://localhost",
			"PORT": 3000
		}
	}
	```

	`mup setup`- install packages needed  
	`mup deploy`
	`nginx -t` to check

---
## Quick Notes

`{{> template}}`
`{{#each collection}} {{/each}}`
`{{#if condition}} {{else}} {{/if}}`
`{{text}}`
`{{URL]}}`
























