<?php

$navbar = [
    [
        'type' => 'container',
        'children' => [
            [
                'type' => 'anchor',
                'settings' => [
                    'href' => '/',
                ],
                'children' => [
                    [
                        'type' => 'text',
                        'settings' => [
                            'value' => 'Home'
                        ]
                    ]
                ]
            ],
            [
                'type' => 'anchor',
                'settings' => [
                    'href' => '/about',
                ],
                'children' => [
                    [
                        'type' => 'text',
                        'settings' => [
                            'value' => 'About'
                        ]
                    ]
                ]
            ]
        ]
    ],
];

$documents = [

    // Home page
    [
        'slug' => null,
        'elements' => array_merge($navbar, [
            [
                'type' => 'heading',
                'children' => [
                    [
                        'type' => 'text',
                        'settings' => [
                            'value' => 'My Website',
                        ]
                    ]
                ]
            ],
            [
                'type' => 'paragraph',
                'children' => [
                    [
                        'type' => 'text',
                        'settings' => [
                            'value' => 'Welcome to my awesome website!',
                        ]
                    ]
                ]
            ],
            [
                'type' => 'paragraph',
                'children' => [
                    [
                        'type' => 'text',
                        'settings' => [
                            'value' => 'Have you heard about this ',
                        ]
                    ],
                    [
                        'type' => 'strong',
                        'children' => [
                            [
                                'type' => 'text',
                                'settings' => [
                                    'value' => 'new',
                                ]
                            ]
                        ]
                    ],
                    [
                        'type' => 'text',
                        'settings' => [
                            'value' => ' service called ',
                        ]
                    ],
                    [
                        'type' => 'anchor',
                        'settings' => [
                            'target' => '_blank',
                            'href' => 'https://google.com',
                        ],
                        'children' => [
                            [
                                'type' => 'text',
                                'settings' => [
                                    'value' => 'Google',
                                ]
                            ]
                        ]
                    ],
                    [
                        'type' => 'text',
                        'settings' => [
                            'value' => '? It\'s a great way to find stuff on the interwebs. Check it out!',
                        ]
                    ]
                ]
            ]
        ])
    ],

    // About
    [
        'slug' => 'about',
        'elements' => array_merge($navbar, [
            [
                'type' => 'heading',
                'children' => [
                    [
                        'type' => 'text',
                        'settings' => [
                            'value' => 'Let me tell you about me',
                        ]
                    ]
                ]
            ]
        ])
    ]
];

$slug = request()->route('slug');

$document = \Illuminate\Support\Arr::first($documents, function($document) use ($slug) {
    return $document['slug'] == $slug;
});

if (!$document) {
    abort(404);
}

function render_page_content($elements)
{
    foreach ($elements as $element) {
        if ($tag = get_element_tag($element)) {
            $attributes = get_element_attributes($element);

            echo '<' . $tag . ($attributes ? ' ' . array_to_html_attributes($attributes) : '') . '>';
        }

        if ($value = $element['settings']['value'] ?? null) {
            echo $value;
        }

        if (isset($element['children'])) {
            render_page_content($element['children']);
        }

        if ($tag) {
            echo '</' . $tag . '>';
        }
    }
}

function get_element_tag($element)
{
    switch ($element['type']) {
        case 'heading':
            return 'h1';
        case 'paragraph':
            return 'p';
        case 'strong':
            return 'strong';
        case 'anchor':
            return 'a';
        case 'container':
            return 'div';
    }

    return null;
}

function get_element_attributes($element)
{
    $attributes = [];

    switch ($element['type']) {
        case 'anchor':
            switch ($element['settings']['target'] ?? null) {
                case '_blank':
                    $attributes['target'] = $element['settings']['target'];
                    break;
            }

            if ($href = $element['settings']['href'] ?? null) {
                $attributes['href'] = $href;
            }
            break;
    }

    return $attributes;
}

function array_to_html_attributes($array)
{
    array_walk($array, function ($val, $key) use (&$result) {
        if ($result) {
            $result .= ' ';
        }

        $result .= "$key=\"$val\"";
    });

    return $result;
}

?>
<!doctype html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport"
          content="width=device-width, user-scalable=no, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0">
    <meta http-equiv="X-UA-Compatible" content="ie=edge">
    <title>The best CMS in the world</title>
</head>
<body>

{!! render_page_content($document['elements']) !!}

</body>
</html>