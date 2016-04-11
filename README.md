# hubot-wakeup-ec2

Start your EC2 instance

See [`src/wakeup-ec2.coffee`](src/wakeup-ec2.coffee) for full documentation.

## Installation

In hubot project repo, run:

`npm install hubot-wakeup-ec2 --save`

Then add **hubot-wakeup-ec2** to your `external-scripts.json`:

```json
[
  "hubot-wakeup-ec2"
]
```

## Sample Interaction

```
uyou>> hubot start instance tag-name=tag-value
hubot>> started instance (instanceId = xxxxxxx)
```
