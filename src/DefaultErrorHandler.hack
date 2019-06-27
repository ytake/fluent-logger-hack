namespace Ytake\Fluent\Logger;

use namespace HH\Lib\Str;
use function error_log;
use function json_encode;

final class DefaultErrorHandler implements ErrorHandlerInterface {

  public async function handleAsync(
    classname<FluentLogger> $logger,
    Entity $entity,
    string $error
  ): Awaitable<void> {
    error_log(
      Str\format(
        "%s %s %s: %s",
        $logger,
        $error,
        $entity->getTag(),
        json_encode($entity->getData())
      )
    );
  }
}
