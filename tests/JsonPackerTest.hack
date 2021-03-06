use type Ytake\Fluent\Logger\{Entity, JsonPacker};
use type Facebook\HackTest\{DataProvider, HackTest};
use function Facebook\FBExpect\expect;

final class JsonPackerTest extends HackTest {

  const string TAG = "hack.testing";
  const int EXPECTED_TIME = 123456789;
  private dict<arraykey, mixed> $expectedData = dict[];

  private static function expectedData(): dict<arraykey, mixed> {
    return dict[
      "abc" => "def"
    ];
  }

  public static function provideToEntity(): varray<vec<Entity>> {
    return varray[
      vec[
        new Entity(
          self::TAG,
          self::expectedData(),
          self::EXPECTED_TIME
        )
      ],
    ];
  }

  <<DataProvider('provideToEntity')>>
  public function testShouldReturnExpectedPackResult(
    Entity $entity
  ): void {
    $packer = new JsonPacker();
    expect($packer->pack($entity))->toMatchRegExp('/["%s",%d,{"%s":"%s"}]/');
  }

  <<DataProvider('provideToEntity')>>
  public function testShouldReturnPackTag(
    Entity $entity
  ): void {
    expect($entity->getTag())->toBeSame(self::TAG);
  }

  <<DataProvider('provideToEntity')>>
  public function testShouldReturnPackTime(
    Entity $entity
  ): void {
    expect($entity->getTime())->toBeSame(self::EXPECTED_TIME);
  }

  <<DataProvider('provideToEntity')>>
  public function testShouldReturnPackData(
    Entity $entity
  ): void {
    expect($entity->getData())->toBeSame(self::expectedData());
  }
}
