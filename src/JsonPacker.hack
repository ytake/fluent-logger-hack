namespace Ytake\Fluent\Logger;

use function json_encode;

final class JsonPacker implements PackerInterface {

  public function pack(
    Entity $entity
  ): string {
    return json_encode(
      vec[
        $entity->getTag(),
        $entity->getTime(),
        $entity->getData()
      ]
    );
  }
}
