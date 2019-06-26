use type Ytake\Fluent\Logger\Entity;
use type Facebook\HackTest\HackTest;
use function time;
use function Facebook\FBExpect\expect;

final class EntityTest extends HackTest {
  private string $tag = 'hack.testing';

  public function testShouldReturnExpectedEntity(): void {
    $expectedLog = dict[
      "abc" => "def"
    ];
    $time = time();
    $entity = new Entity($this->tag, $expectedLog, $time);
    expect($entity->getTag())->toBeSame($this->tag);
    expect($entity->getData())->toBeSame($expectedLog);
    expect($entity->getTime())->toBeSame($time);
    $entity = new Entity($this->tag, $expectedLog);
    expect($time)->toBeGreaterThanOrEqualTo($entity->getTime());
  }
}
