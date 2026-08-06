# Work packages:
+-------------------------------------------------------+
|                 CPU Core & L1/L2 Cache                |
+-------------------------------------------------------+
                 Cache Miss / Snoop
                        │
                        ▼
+-------------------------------------------------------+
| 1. PROTOCOL LAYER                                     |
|-------------------------------------------------------|
| • Cache coherency state machine                       |
| • MOESI/CHI state transitions                         |
| • Select CHI transaction                              |
|   (ReadShared, ReadUnique, Evict, ...)                |
| • Interpret incoming RSP/DAT/SNP                      |
+-------------------------------------------------------+
                        │
                        ▼
+-------------------------------------------------------+
| 2. TRANSACTION LAYER                                  |
|-------------------------------------------------------|
| • Allocate TxnID                                      |
| • Outstanding transaction table                       |
| • Destination NodeID (HN)                             |
| • Retry handling                                      |
| • Ordering / dependency tracking                      |
+-------------------------------------------------------+
                        │
                        ▼
+-------------------------------------------------------+
| 3. LINK LAYER                                         |
|-------------------------------------------------------|
| • Build req_flit_t                                    |
| • Build rsp_flit_t                                    |
| • Build dat_flit_t                                    |
| • Build snp_flit_t                                    |
| • Credit management                                   |
| • TXREQ/TXRSP/TXDAT                                   |
+-------------------------------------------------------+
                        │
                        ▼
                  CHI Interconnect