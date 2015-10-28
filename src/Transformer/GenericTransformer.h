/*
 * GenericTransformer.h
 *
 * Created on: Jul 30, 2015
 *     Author: dpayne
 */

#ifndef _VIS_GENERIC_TRANSFORMER_H
#define _VIS_GENERIC_TRANSFORMER_H

#include "Writer/GenericWriter.h"
#include "Domain/VisTypes.h"

namespace vis
{

class GenericTransformer
{
  public:
    explicit GenericTransformer();

    virtual ~GenericTransformer();

    virtual void execute_stereo(pcm_stereo_sample *buffer,
                                vis::GenericWriter *writer) = 0;
    virtual void execute_mono(pcm_stereo_sample *buffer,
                              vis::GenericWriter *writer) = 0;

  protected:
    virtual int32_t get_window_width() const;

    virtual int32_t get_window_height() const;
};
}

#endif
