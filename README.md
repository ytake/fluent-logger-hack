# Fluent Logger Hack

## Requirements

HHVM 4.8 or higher  
fluentd v0.9.20 or higher

## Example

```hack
require_once __DIR__ . '/vendor/hh_autoload.php';

use namespace Ytake\Fluent\Logger;

<<__EntryPoint>>
async function main(): Awaitable<void> {
  $logger = new Logger\FluentLoggerFactory();
  await using ($l = $logger->getLogger('1.2.3.4')) {
    $l->sendLogAsync('hack.testing', dict[
      'message' => 'send.'
    ]);
  };
}

```
