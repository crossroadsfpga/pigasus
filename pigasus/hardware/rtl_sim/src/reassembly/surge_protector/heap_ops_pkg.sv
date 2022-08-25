package heap_ops_pkg;

typedef enum logic [1:0] {
    HEAP_OP_ENQUE = 0,
    HEAP_OP_DEQUE_MIN,
    HEAP_OP_DEQUE_MAX
} heap_op_t;

endpackage
