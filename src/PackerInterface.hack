namespace Ytake\Fluent\Logger;

interface PackerInterface {

  public function pack(
    Entity $entity
  ): string;
}
