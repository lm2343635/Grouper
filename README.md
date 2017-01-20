# Grouper
A group finance manager application: Grouper, using mutiple untrusted servers.

# Introduction
Conventional mobile applications are built based on a client-server mode. This requires central servers for storing shared data. The users of such mobile applications must fully trust the central server and their application providers. If a central server is compromised by hackers, user information may be revealed because data is often stored on the server in cleartext. Users may lose their data when service providers shut down their services. 

A popular approach to address the central server problem is using P2P(Peer to Peer) to transfer user data between devices. However, there is an obvious problem in such a P2P approach. Data transfer can only be finished during two devices are online at the same time. Another problem is that the number of P2P connections becomes large  fast as the number of users increases. 

We are implementing a mobile application that is not relied on trusted central servers. Concretely, we are developing a group finance manager application. We call it Grouper. Unlike P2P systems, we use multiple untrusted servers for data transfer. Data is divided into several pieces and uploaded to diverse servers. Each server can only keep a piece of data temporarily. A piece will be deleted after a period of time. Those two methods ensure that user data cannot be cracked easily. In addition, all devices of group members keep a complete data set, and data can be recovered even untrusted servers shut down.

# Design

We design a group finance manager application, Grouper, on mobile devices. This does not rely on trusted central servers. 

# Group Finance Manager
 In Grouper, group members generate records about amounts of money, classifications, accounts, shops, remarks and times in their devices. For example, Alice records that she ate breakfast (classification) in the center canteen (shop) at 8:00 AM (time) on November 1st, 2016, and she paid her breakfast by her credit card (account). These items are created by users as they want. They can choose an item from existing ones when they want to add new records.

 With data synchronization, group members can also share their records with other group members. Therefore, group income and expenditure information are analyzed and shown to all members. Grouper uses multiple untrusted servers to synchronize and avoids relying on trusted central servers. To create a group in Grouper, the owner of this group needs to register and set access keys in untrusted servers. The owner passes the access keys to group members by a face-to-face way.

# Shamir's Secret Sharing
In Grouper, secret sharing plays an indispensable role in protecting user data from getting lost or destroyed. In a secret sharing scheme, a dealer securely shares a secret with a group of members by generating $n$ shares using a cryptographic function\cite{smith2013layered}. At least $k$ or more shares can reconstruct the secret, but $k-1$ or fewer shares can obtain nothing about the secret\cite{pang2005new}. We describe this scheme as a function $f(k, n)$, where $n$ is the number of all shares, and $k$ is the threshold to combine shares.  We use Shamir's secret sharing that  is a popular technique to implement threshold schemes.

# Data Synchronization Using Multiple Untrusted Servers

We design Grouper based on data synchronization through multiple untrusted servers rather than a single server. There are three principles in our proposal. 

Firstly, a server transfers data as similar to a router, but does not keep it permanently. Most current popular client-server applications store their user data on several central servers, and the user's data will not be deleted unless the user deletes his account. Grouper uses untrusted servers as a bridge for transferring data. Consider that a group includes three members: Alice, Bob and Carol. Alice creates a new record in her device, this record is uploaded to untrusted servers, and the record on servers will be deleted after Bob and Carol download it from servers.

Secondly, a server keeps data temporarily. We define a period of time in which data can be kept in a server. In this paper, we set this period to 1 hour for our example situations. The record Alice uploaded to untrusted servers can exist for 1 hour. After 1 hour since uploaded, this record will be deleted. Alice requires to upload this record again to serves until all of other members have downloaded successfully. The longer keeping period means the higher risk of data reveal. We will find suitable periods as the number of group members, security requirement and others. 

Thirdly, servers do not know the cleartext of data. Keeping data temporarily cannot ensure data security, because servers know the cleartext of data in this temporary period. For this problem, developers often encrypt data before uploading to servers, and this needs a decryption key to decrypt data in other devices. In order to distribute the decryption key, users should share it by themselves. In Grouper, we do not encrypt data but we use a secret sharing scheme as described in Section 2.2. Servers do not know the cleartext of a share generated by a secret sharing scheme.
