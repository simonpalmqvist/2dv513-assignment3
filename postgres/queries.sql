-- 1. Create and get new user id
insert into users (id)
select
  md5(
    concat(
      CURRENT_TIMESTAMP::text,
      random()::text
    )
  )
returning *;

-- 2. Get users recipe for today (if user already has a recipe for the day)
SELECT
  r.id,
  r.name,
  r.image,
  r.tag
FROM
  history h
INNER JOIN
  recipes r on h.recipe_id = r.id
WHERE
  h.user_id = $1 AND
  h.used_at = CURRENT_DATE;

-- 3. Get a new recipe and add it to history
with random_recipe as (
  SELECT
    id,
    name,
    image,
    tag
  FROM
    recipes
  WHERE
    id NOT IN (SELECT recipe_id FROM history WHERE user_id = $1 ORDER BY used_at desc limit 2)
  ORDER BY
    RANDOM()
  LIMIT 1
),
inserted as (
  INSERT INTO history (user_id, recipe_id, used_at)
  SELECT
    $1,
    id,
    CURRENT_DATE
  FROM
    random_recipe
)
SELECT * FROM random_recipe;

-- 4. Get ingredients for recipe
SELECT
  *
FROM
  ingredients
WHERE
  recipe_id = $1;

-- 5. Get instructions for recipe
SELECT
  *
FROM
  instructions
WHERE
  recipe_id = $1
ORDER BY
  step;
