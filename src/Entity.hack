namespace Ytake\Fluent\Logger;

use function time;

<<__ConsistentConstruct>>
class Entity {

  public function __construct(
    protected string $tag,
    protected dict<arraykey, mixed> $data = dict[],
    protected num $time = time()
  ) {}

  public function getTag(): string {
    return $this->tag;
  }

  public function getData(): dict<arraykey, mixed> {
    return $this->data;
  }

  public function getTime(): num {
    return $this->time;
  }
}
