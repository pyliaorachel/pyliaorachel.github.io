---
layout: post
title:  "Linked List Basic"
categories: Blog Notes DataStructure
tags: "data structure"
author: pyliaorachel
comments: true
prerequisites: ["C"]
excerpt_separator: <!--more-->
---

>## Content
>1. What is Linked List?
>2. Linked List v.s. Array
>3. Visualizing Linked List
>4. Basic examples (in C)

<!--more-->

# What is Linked List?

*Linked lists* use __dynamically allocated memories__ as data storage, and associate these storages with __pointers__. 

Well, you may just think of *linked lists* as arrays that are __resizable__, easily __rearrangible__, with __non-consecutive__ slots. 

# Linked List v.s. Array

Everyone likes comparisons. So the properties of linked list & array here -

| Linked List           | Array              	     |
|:----------------------|:---------------------------|
| * Dynamic size        | Fixed size            	 |
| * Cheaper insertion   | Expensive insertion   	 |
| No random access      | * Random Access      		 |
| ---			        | * Better cache performance |
| Extra memory space    | * ---                 	 |

+ We must know how many elements to allow when defining an array; __linked lists__ allowes more flexibility.

+ To insert an element into array, we probably need to move a whole bunch of elements backwards for the newcomer to fit. For __linked lists__, it's just about switching between some pointers and that's it.

+ Memories are allocated consecutively for arrays, which mean calculating `arr[5]`, `arr[10]`, `arr[1000]` are all about adding offsets to `arr[0]`, which is quite cheap. But for __linked lists__, the memories are dynamically allocated on heap and do not have this luxury.

+ Moreover for consecutive memories, the cache performance is better, since a whole bunch of array elements that fit into the cache size will be fetched all at once.

+ __Linked lists__ requires more memory space than arrays due to the fact that pointers are required.

# Visualizing Linked List

OK, so what's the picture of *linked lists*? It all starts with a pointer (`*list`), followed by a list of nodes (`node_i`):

```

  []   ->   [_]  ->  [_]  -> ...  ->  [_]  ->  NULL
*list 	  node_1   node_2    ...    node_N

```

Hold on, some structures need to be defined for __lists__ and __nodes__ before you can easily mingle with the crazy pointers.

```c

struct Node {
	int value; // holding the value of the node; can be any type or have multiple value fields
	struct Node *next; // pointing to the next node in list
};

typedef struct Node Node;

struct SinglyLinkedList {
	Node *head; // pointing to the first node in list
	int size; // count of nodes in list; optional field
};

typedef struct SinglyLinkedList SinglyLinkedList;

```

>#### Haven't seen `typedef` before?
> `typedef` provides an easy way to define types so that you don't have to type in so many words when declaring a variable with that data type.

> + `typedef [actual-data-type] [a-convenient-name]`

> So in C, after defiing a struct (e.g. Node), everytime you wanna declare a Node, you type `struct Node n`. Now I know how to alias `struct Node` into `Node` by `typedef`!

> + `typedef struct Node Node;`

Then we're ready to use these structs and build a linked list.

# Basic examples (in C)

### Initialization

```c

SinglyLinkedList *list = NULL;
Node *n = NULL;
Node *temp_n = NULL;

list = malloc(sizeof(SinglyLinkedList));
list->head = NULL;
list->size = 0;

```

> `malloc` stands for memory allocation, which is similar to the `new` keyword in C++.  
> You pass in the size of memory you want to allocate, so for a `SinglyLinkedList` struct, its
> `sizeof(SinglyLinkedList)`.

### Adding a node to list

```c

/*      []     ->    NULL   */
/*    *list                 */

// create a node
n = malloc(sizeof(Node));
n->value = 1; // give the node a value
n->next = NULL; // the node is not linked by other nodes yet

// add it to the head of the list
list->head = n;
list->size++;

/*      []     ->    [1]    ->     NULL   */
/*    *list           ↑                   */
/*                   *n      			  */

// remove it from the list
list->head = NULL;
list->size--;

/*      []  ->		NULL	[1] ->  NULL   */
/*    *list                  ↑             */
/*                           *n       	   */

// destroy it by releasing its memory
free(n);

/*      []     ->    NULL   */
/*    *list                 */

```

> Always free your malloc'ed memories to avoid memory leak.

### Adding nodes to list

```c

// declare pointer temp_n to point to the head of the empty list
temp_n = list->head;

for (int i = 0; i < 1000; i++) {
	// create new node
	n = malloc(sizeof(Node));
	n->value = i;
	n->next = NULL;

	// add to the head of the list
	if (list->head == NULL) { // if list empty, let head point to n
		list->head = n;
	} else { // else let the currently pointed node link to n (by assigning *next to point to n)
		temp_n->next = n;
	}
	temp_n = n;
	list->size++;
}

/*      []  -> [0] -> [1] -> [2] -> ... -> [999] ->  NULL   */
/*    *list     ↑  ->  ↑  ->  ↑     ... ->   ↑    	        */
/*          *temp_n *temp_n *temp_n        *temp_n 			*/

```

> Use a temp node pointer to move around the list.

### List traversal

```c

int sum = 0;
temp_n = list->head;

while (temp_n != NULL) {
	printf("value: %d\n", temp_n->value);
	sum += temp_n->value;
	temp_n = temp_n->next; // move forward the cursor
}

printf("sum: %d\n", sum);
```

### Insert a node into list

```c

/*      []  -> [0] -> [1] -> [2] -> ... -> [999] ->  NULL   */
/*    *list 											    */

int index = 5; // inserting into index 5 of list
n = malloc(sizeof(Node));
n->value = 87;
n->next = NULL;

// traverse through the list to find index; assume we don't check if index is valid
temp_n = list->head;

for (int i = 0; i < index-1; i++) {
	temp_n = temp_n->next;
}

/*      []  -> ... -> [4] -> [5] -> ... ->  NULL   */
/*    *list            ↑                           */
/*                  *temp_n                        */

// insert by moving around pointers
n->next = temp_n->next;
temp_n->next = n;

/*                    *n  -> [87]	                       */
/*                             ↓                           */
/*      []  -> ... -> [4] ->  [5]   -> ... ->  NULL        */
/*    *list            ↑                                   */
/*                  *temp_n                                */

/*                    *n  -> [87]	                       */
/*                         ⬈   ↓                           */
/*      []  -> ... -> [4]     [5]   -> ... ->  NULL        */
/*    *list            ↑                                   */
/*                  *temp_n                                */

list->size++;

```

### Remove a node from list

```c

index = 5; // removing node at index 5 of list

// traverse through the list to find index; assume we don't check if index is valid
temp_n = list->head;

for (int i = 0; i < index-1; i++) {
	temp_n = temp_n->next;
}

/*      []  -> ... -> [4] -> [87] -> ... ->  NULL  */
/*    *list            ↑                           */
/*                  *temp_n                        */

// remove by moving around pointers; notice that we're removing temp_n->next instead of temp->n
n = temp_n->next; // n = node to remove
temp_n->next = n->next; // connect the previous node and the next node

/*                    		  *n	                       */
/*                             ↓                           */
/*      []  -> ... -> [4] ->  [87]   -> ... ->  NULL       */
/*    *list            ↑                                   */
/*                  *temp_n                                */

/*                    		  *n	                                */
/*                             ↓                                    */
/*      []  -> ... -> [4]     [87]   ->  [5]  -> ... ->  NULL       */
/*    *list            ↑  \_____________⬈	                        */
/*                  *temp_n                                         */

free(n); // release memory
list->size--;	

```

### Destroy the whole list before program ends

```c

while (list->head != NULL) {
	temp_n = list->head;
	list->head = list->head->next;
	free(temp_n);
}

// finally, free list as well
free(list);

```

# Summary

__Linked lists__ are the most basic data structure to know and deal with, and its application is wide, such as creating trees. Make sure you can construct a valid linked list before you move on to the more complicated pointer-related data structure!

Source code can be found at [GitHub](https://github.com/pyliaorachel/data-structure-and-algorithm/blob/master/DataStructures/LinkedList/Implementations/linked-list.c).

>#### References <br>
>* [GeeksforGeeks - Linked List vs Array](http://www.geeksforgeeks.org/linked-list-vs-array/)