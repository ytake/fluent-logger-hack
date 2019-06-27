namespace Ytake\Fluent\Logger;

interface ErrorHandlerInterface {

  public function handleAsync(
    classname<FluentLogger> $logger,
    Entity $entity,
    string $error
  ): Awaitable<void>;
}
