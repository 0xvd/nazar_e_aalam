<?php

namespace App\Repositories;

use Illuminate\Database\Eloquent\Model;

class BaseRepository
{
    /**
     *  Repository model.
     *
     * @var Model
     */
    protected Model $model;


    public function __call($name, $arguments)
    {
        return $this->model->{$name}(...$arguments);
    }
}
