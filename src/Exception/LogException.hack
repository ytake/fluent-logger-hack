namespace Ytake\Fluent\Logger\Exception;

use type Exception;
use type Ytake\Fluent\Logger\Entity;

final class LogException extends Exception {

  public function __construct(
    protected Entity $entity,
    protected string $message = "",
    protected int $code = 0,
    protected ?Exception $previous = null)
  {
    parent::__construct($message, $code, $previous);
  }

  public function getEntity(): Entity {
    return $this->entity;
  }
}
