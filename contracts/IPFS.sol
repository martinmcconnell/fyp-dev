pragma solidity >=0.7.0 <0.9.0;


contract IpfsContract {
    string public ipfsHash;

    function get() external view returns (string memory) {
        return ipfsHash;
    }

    function add(bytes memory _ipfsHash) public {
        ipfsHash = _ipfsHash;
    }
}