pragma solidity ^0.8.0;

contract HeroLarge {
    struct Accessory {
        uint64 strength;
    }

    struct Hero {
        uint256 id;
        Accessory sword;
        Accessory shield;
        Accessory hat;
        Accessory[] accessoriesVector;
    }

    mapping(address => Hero) public heroes;

    function createHeroes() public {
        Hero storage h = heroes[msg.sender];
        h.id = 0;
        h.sword = Accessory(0);
        h.shield = Accessory(0);
        h.hat = Accessory(0);
        for (uint j = 0; j < 200; j++) {  // Or 20
            h.accessoriesVector.push(Accessory(0));
        }
        // Simulate 10 by overwriting; for real, use array of Heroes if needed
    }

    function accessHero() public view returns (uint64) {
        Hero memory h = heroes[msg.sender];
        uint64 total = 0;
        for (uint i = 0; i < 1000; i++) {
            total += h.sword.strength + h.shield.strength + h.hat.strength;
            if (h.accessoriesVector.length > 0) total += h.accessoriesVector[0].strength;
        }
        return total;
    }

    function updateHero() public {
        Hero storage h = heroes[msg.sender];
        for (uint i = 0; i < 1000; i++) {
            h.sword.strength += 10;
            h.shield.strength += 10;
            h.hat.strength += 10;
            if (h.accessoriesVector.length > 0) h.accessoriesVector[0].strength += 10;
        }
    }

    function deleteHero() public {
        delete heroes[msg.sender];
    }
}
