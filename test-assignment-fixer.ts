// test-assignment-fixer.ts
// Run this file through dprint to test the assignment fixer plugin

// Test 1: Short assignments should stay on one line
const shortVar = 42;
const another = "value";

// Test 2: Medium assignments that were broken should be fixed
const mediumVariable
=
someValue;

const anotherMedium
=
anotherValue
+ 10;

// Test 3: Long assignments should be wrapped in parentheses
const thisIsAVeryLongVariableNameThatWillExceedTheLimit
=
thisIsAnotherVeryLongExpressionThatWillDefinitelyExceedTheLineLimit;

// Test 4: Method chaining with assignment
const result
=
someObject
  .method()
  .anotherMethod()
  .chain();

// Test 5: Array destructuring
const [first, second]
=
someArray;

// Test 6: Object destructuring (should add parentheses if standalone)
{ x, y }
=
coordinates;

// Test 7: Nested destructuring
const { data: { items } }
=
response;

// Test 8: Assignment in conditionals (should not break)
if (value = getValue()) {
  console.log(value);
}

// Test 9: Multiple assignments
let a
=
1,
    b
=
2,
    c
=
3;

// Test 10: Object properties (should not be affected)
const config = {
  option1:
    true,
  option2:
    false,
  longPropertyName:
    someVeryLongValueThatMightCauseLineBreaks
};

// Test 11: Binary expressions with other operators (should remain as is)
const calculation = 10
  + 20
  * 30
  / 40;

// Test 12: Logical operators (should remain as is)  
const condition = someCondition
  && anotherCondition
  || thirdCondition;

// Test 13: Assignment with function call
const data
=
fetchData(
  param1,
  param2
);

// Test 14: Assignment in class
class MyClass {
  property
  =
  initialValue;
  
  method() {
    this.property
    =
    newValue;
  }
}

// Test 15: Assignment with template literal
const message
=
`Hello ${name}, welcome to ${place}`;

// Test 16: Export assignment
export const exportedVar
=
someValue;

// Test 17: Assignment with await
async function test() {
  const result
  =
  await someAsyncFunction();
}

// Test 18: Assignment with type annotation
const typed: string
=
"value";

// Test 19: Assignment in for loop
for (let i
     =
     0; i < 10; i++) {
  console.log(i);
}

// Test 20: Complex expression that should be wrapped
const complexCalculation
=
(someValue * 2 + anotherValue / 3) * (yetAnotherValue - 4) + bonusValue;