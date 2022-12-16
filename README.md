# Fundraising

by Ivo Reich & Michael Breier

With this smart contract you can create decentralised fundraising campaigns. You can create a campaign by specifing a name, a purpose, one or more beneficiaries, a goal amount and a deadline. The creator of the campaign can even suspend it later on. One can contribute to a campaign by spending multiples of 0.001 until the deadline or the goal amount is reached. After that, beneficiaries of a campaign are then allowed to to withdraw and collect the raised amount of the campaign. Besides those possibilities of interaction, there are various views offered, e.g. for getting all campaigns, get the missing amount or the remaining time for a campaign or contributons.

To use this dapp make sure you connect to the Sepolia testnetwork by following the steps beyond:

1. Rename `config.example.json` to `config.json` and fill in your MNEMONIC and INFURA_API_KEY. Also make sure you have npm package `@truffle/hdwallet-provider` installed. (by installing with `npm install`)
2. The ABI `Fundraising.json` is already provided in `build\contracts\`. That means you can either connect with the test deployment by hitting `truffle console --network sepolia` or deploy your own instance for example locally by entering `truffle migrate` and then access it with `truffle console` (if you want to redeploy on Sepolia you will have to use `truffle migrate --reset` first).
3. Dispense the following command to get an instance which you then can interact with `let instance = await Fundraising.deployed()`

The contract is deployed on the Sepolia test network and is accessible under the following address: **0xFDeC47B667f4c3DdEab5F909b05cC778E7d3b1DC** ([Etherscan Contract](https://sepolia.etherscan.io/address/0x6364c54E3213768f3B394e8C9FC38532EC310768))

<br><hr><br>

## Getters

For the view methods, of course, you do not need to provide any gas, as there are no state changing transactions involved.

### Get Campaigns

Get all campaigns:

_getCampaigns() public view returns (Campaign[] memory)_

```js
instance.getCampaigns();
```

### Get Campaigns Count

Get campaigns count:

_getCampaignsCount() public view returns (uint)_

```js
instance.getCampaignsCount();
```

### Get Index by Name

Get the index of the campaign by its name:

_getIndexByName(string memory \_name)_

```js
instance.getIndexByName('Fundme');
```

### Get Missing Amount

Get the missing amount in wei:

_getMissingAmount(uint \_index) public view returns (uint)_

```js
instance.getMissingAmount('0');
```

### Get Campaign Contributions

Get campaign contributions by contributor:

_getCampaignContributions(uint \_index, address \_contributor) public view returns (uint)_

```js
instance.getCampaignContributions(
    '0',
    '0xEB343197962A455dd81dDabc0a5Ca1a9c231E8E5'
);
```

### Get Total Contributions

Get contributions of all campaigns by contributor:

_getTotalContributions(address \_contributor) public view returns (uint)_

```js
instance.getTotalContributions('0xEB343197962A455dd81dDabc0a5Ca1a9c231E8E5');
```

<br><hr><br>

## Fundraising Interaction

Get active and start with fundraising or contributing by using this contracts interaction methods. Please make sure that you fullfill the requirements of the individual methods to make the calls successfull (you can do so using the view methods providing the relevant data to check by yourself), otherwise your execution will be reverted and the gas used until this point will be lost.

### Create a campaign

Create a fundraising campaign:

_create(string memory \_name, string memory \_purpose, address[] memory \_beneficiaries, uint \_goalAmount, uint \_deadline) public_

```js
instance.create(
    'Fundme',
    'Spenden',
    [
        '0xEB343197962A455dd81dDabc0a5Ca1a9c231E8E5',
        '0x1871E702b7e8280E9e031487780e55F5f77Da4e1',
    ],
    web3.utils.toWei('100'),
    Math.floor(new Date('2023-01-01').getTime() / 1000)
);
```

#### Requirements

```
        Name: 0 < Length <= 100, must be unique
        Purpose: 0 < Length <= 1000
        Beneficiaries: Count > 0
        Goal amount: Goal amount > 0, must be multiples of 0.001
        Deadline: Must be within next 365 days after set block time
```

### Suspend

Suspend an existing fundraising campaign:

_suspend(uint \_index) public_

```js
instance.suspend('0');
```

#### Requirements

```
        Campaign: Block time must be before deadline, shall not be completed already
        Transaction: Caller must be the campaign creator
```

### Contribute

Contribute to a fundraising campaign:

_contribute(uint \_index) public payable_

```js
instance.contribute('0', {
    from: 'YOUR FUNDED PUBLIC ADDRESS (THE ONE WITH THE SEPOLIA ETH)',
    value: web3.utils.toWei('0.5'),
});
```

#### Requirements

```
        Campaign: Block time must be before deadline, (shall not be completed already), Raised amount + transaction value shall not be greater than goal amount
        Transaction: Value > 0, must be multiples of 0.001
```

### Collect

Collect a fundraising campaign:

_collect(uint \_index) public_

```js
instance.collect('0');
```

#### Requirements

```
        Campaign: Block time must be after or equal deadline, shall not be completed already, Raised amount > 0, Transaction caller must be one of the beneficiaries
```
