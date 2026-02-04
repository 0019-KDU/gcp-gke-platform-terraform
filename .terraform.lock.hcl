# This file is maintained automatically by "terraform init".
# Manual edits may be lost in future updates.

provider "registry.terraform.io/gavinbunney/kubectl" {
  version     = "1.19.0"
  constraints = ">= 1.14.0"
  hashes = [
    "h1:aQUITuBBjv8WJ+WGI0bOZXXYi5s09pMEyyJmlFnuUbE=",
    "zh:1dec8766336ac5b00b3d8f62e3fff6390f5f60699c9299920fc9861a76f00c71",
    "zh:43f101b56b58d7fead6a511728b4e09f7c41dc2e3963f59cf1c146c4767c6cb7",
    "zh:4c4fbaa44f60e722f25cc05ee11dfaec282893c5c0ffa27bc88c382dbfbaa35c",
    "zh:51dd23238b7b677b8a1abbfcc7deec53ffa5ec79e58e3b54d6be334d3d01bc0e",
    "zh:5afc2ebc75b9d708730dbabdc8f94dd559d7f2fc5a31c5101358bd8d016916ba",
    "zh:6be6e72d4663776390a82a37e34f7359f726d0120df622f4a2b46619338a168e",
    "zh:72642d5fcf1e3febb6e5d4ae7b592bb9ff3cb220af041dbda893588e4bf30c0c",
    "zh:9b12af85486a96aedd8d7984b0ff811a4b42e3d88dad1a3fb4c0b580d04fa425",
    "zh:a1da03e3239867b35812ee031a1060fed6e8d8e458e2eaca48b5dd51b35f56f7",
    "zh:b98b6a6728fe277fcd133bdfa7237bd733eae233f09653523f14460f608f8ba2",
    "zh:bb8b071d0437f4767695c6158a3cb70df9f52e377c67019971d888b99147511f",
    "zh:dc89ce4b63bfef708ec29c17e85ad0232a1794336dc54dd88c3ba0b77e764f71",
    "zh:dd7dd18f1f8218c6cd19592288fde32dccc743cde05b9feeb2883f37c2ff4b4e",
    "zh:ec4bd5ab3872dedb39fe528319b4bba609306e12ee90971495f109e142d66310",
    "zh:f610ead42f724c82f5463e0e71fa735a11ffb6101880665d93f48b4a67b9ad82",
  ]
}

provider "registry.terraform.io/hashicorp/google" {
  version     = "6.50.0"
  constraints = ">= 5.0.0, < 7.0.0"
  hashes = [
    "h1:IuhegLJHFR52WoVCAjFdkaxfcmIxplIYlHZbgi0dQ70=",
    "zh:1f3513fcfcbf7ca53d667a168c5067a4dd91a4d4cccd19743e248ff31065503c",
    "zh:3da7db8fc2c51a77dd958ea8baaa05c29cd7f829bd8941c26e2ea9cb3aadc1e5",
    "zh:3e09ac3f6ca8111cbb659d38c251771829f4347ab159a12db195e211c76068bb",
    "zh:7bb9e41c568df15ccf1a8946037355eefb4dfb4e35e3b190808bb7c4abae547d",
    "zh:81e5d78bdec7778e6d67b5c3544777505db40a826b6eb5abe9b86d4ba396866b",
    "zh:8d309d020fb321525883f5c4ea864df3d5942b6087f6656d6d8b3a1377f340fc",
    "zh:93e112559655ab95a523193158f4a4ac0f2bfed7eeaa712010b85ebb551d5071",
    "zh:d3efe589ffd625b300cef5917c4629513f77e3a7b111c9df65075f76a46a63c7",
    "zh:d4a4d672bbef756a870d8f32b35925f8ce2ef4f6bbd5b71a3cb764f1b6c85421",
    "zh:e13a86bca299ba8a118e80d5f84fbdd708fe600ecdceea1a13d4919c068379fe",
    "zh:f569b65999264a9416862bca5cd2a6177d94ccb0424f3a4ef424428912b9cb3c",
    "zh:fec30c095647b583a246c39d557704947195a1b7d41f81e369ba377d997faef6",
  ]
}

provider "registry.terraform.io/hashicorp/google-beta" {
  version     = "6.50.0"
  constraints = ">= 5.0.0, < 7.0.0"
  hashes = [
    "h1:0rqO/ZF1GzTE+wfyk6z84sSis7bkl/s48PcRWYwz8hw=",
    "zh:18b442bd0a05321d39dda1e9e3f1bdede4e61bc2ac62cc7a67037a3864f75101",
    "zh:2e387c51455862828bec923a3ec81abf63a4d998da470cf00e09003bda53d668",
    "zh:3942e708fa84ebe54996086f4b1398cb747fe19cbcd0be07ace528291fb35dee",
    "zh:496287dd48b34ae6197cb1f887abeafd07c33f389dbe431bb01e24846754cfdd",
    "zh:6eca885419969ce5c2a706f34dce1f10bde9774757675f2d8a92d12e5a1be390",
    "zh:710dbef826c3fe7f76f844dae47937e8e4c1279dd9205ec4610be04cf3327244",
    "zh:777ebf44b24bfc7bdbf770dc089f1a72f143b4718fdedb8c6bd75983115a1ec2",
    "zh:9c8703bba37b8c7ad857efc3513392c5a096c519397c1cb822d7612f38e4262f",
    "zh:c4f1d3a73de2702277c99d5348ad6d374705bcfdd367ad964ff4cfd2cf06c281",
    "zh:eca8df11af3f5a948492d5b8b5d01b4ec705aad10bc30ec1524205508ae28393",
    "zh:f41e7fd5f2628e8fd6b8ea136366923858f54428d1729898925469b862c275c2",
    "zh:f569b65999264a9416862bca5cd2a6177d94ccb0424f3a4ef424428912b9cb3c",
  ]
}

provider "registry.terraform.io/hashicorp/helm" {
  version     = "3.1.1"
  constraints = ">= 2.10.0"
  hashes = [
    "h1:aeYsVAdJYzLZYeIu8MIPewY82Jf9/kVmCXcjj+S76NY=",
    "zh:1a6d5ce931708aec29d1f3d9e360c2a0c35ba5a54d03eeaff0ce3ca597cd0275",
    "zh:3411919ba2a5941801e677f0fea08bdd0ae22ba3c9ce3309f55554699e06524a",
    "zh:81b36138b8f2320dc7f877b50f9e38f4bc614affe68de885d322629dd0d16a29",
    "zh:95a2a0a497a6082ee06f95b38bd0f0d6924a65722892a856cfd914c0d117f104",
    "zh:9d3e78c2d1bb46508b972210ad706dd8c8b106f8b206ecf096cd211c54f46990",
    "zh:a79139abf687387a6efdbbb04289a0a8e7eaca2bd91cdc0ce68ea4f3286c2c34",
    "zh:aaa8784be125fbd50c48d84d6e171d3fb6ef84a221dbc5165c067ce05faab4c8",
    "zh:afecd301f469975c9d8f350cc482fe656e082b6ab0f677d1a816c3c615837cc1",
    "zh:c54c22b18d48ff9053d899d178d9ffef7d9d19785d9bf310a07d648b7aac075b",
    "zh:db2eefd55aea48e73384a555c72bac3f7d428e24147bedb64e1a039398e5b903",
    "zh:ee61666a233533fd2be971091cecc01650561f1585783c381b6f6e8a390198a4",
    "zh:f569b65999264a9416862bca5cd2a6177d94ccb0424f3a4ef424428912b9cb3c",
  ]
}

provider "registry.terraform.io/hashicorp/kubernetes" {
  version     = "3.0.1"
  constraints = ">= 2.20.0"
  hashes = [
    "h1:2N74MxmxBxBb8KU77GTESCTHtJaLvkMQte/cW4CJnMc=",
    "zh:02d55b0b2238fd17ffa12d5464593864e80f402b90b31f6e1bd02249b9727281",
    "zh:20b93a51bfeed82682b3c12f09bac3031f5bdb4977c47c97a042e4df4fb2f9ba",
    "zh:6e14486ecfaee38c09ccf33d4fdaf791409f90795c1b66e026c226fad8bc03c7",
    "zh:8d0656ff422df94575668e32c310980193fccb1c28117e5c78dd2d4050a760a6",
    "zh:9795119b30ec0c1baa99a79abace56ac850b6e6fbce60e7f6067792f6eb4b5f4",
    "zh:b388c87acc40f6bd9620f4e23f01f3c7b41d9b88a68d5255dec0a72f0bdec249",
    "zh:b59abd0a980649c2f97f172392f080eaeb18e486b603f83bf95f5d93aeccc090",
    "zh:ba6e3060fddf4a022087d8f09e38aa0001c705f21170c2ded3d1c26c12f70d97",
    "zh:c12626d044b1d5501cf95ca78cbe507c13ad1dd9f12d4736df66eb8e5f336eb8",
    "zh:c55203240d50f4cdeb3df1e1760630d677679f5b1a6ffd9eba23662a4ad05119",
    "zh:ea206a5a32d6e0d6e32f1849ad703da9a28355d9c516282a8458b5cf1502b2a1",
    "zh:f569b65999264a9416862bca5cd2a6177d94ccb0424f3a4ef424428912b9cb3c",
  ]
}
