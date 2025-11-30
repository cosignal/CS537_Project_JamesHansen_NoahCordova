pragma solidity ^0.8.0;

contract HeroSmall {
    struct Accessory {
        uint64 strength;
    }

    struct Hero {
        uint256 id;
        Accessory sword;
        Accessory shield;
        Accessory hat;
    }

    mapping(address => Hero) public heroes;

    function createHeroes() public {
        for (uint i = 0; i < 10; i++) {
            heroes[msg.sender] = Hero(i, Accessory(0), Accessory(0), Accessory(0));
        }
    }

    function accessHero() public view returns (uint64, uint64, uint64) {
        Hero memory h = heroes[msg.sender];
        for (uint i = 0; i < 1000; i++) {
            uint64 s = h.sword.strength;
            uint64 sh = h.shield.strength;
            uint64 ha = h.hat.strength;
        }
        return (h.sword.strength, h.shield.strength, h.hat.strength);
    }

    function updateHero() public {
        Hero storage h = heroes[msg.sender];
        for (uint i = 0; i < 1000; i++) {
            h.sword.strength += 10;
            h.shield.strength += 10;
            h.hat.strength += 10;
        }
    }

    function deleteHero() public {
        delete heroes[msg.sender];
    }
}
